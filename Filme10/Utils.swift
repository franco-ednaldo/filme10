import Foundation
import SwiftKuery
import SwiftKueryMySQL

// Classe utilitária para gerenciar conexões e executar operações no banco de dados
class CommonUtils {
    private var pool: ConnectionPool? // Pool de conexões para reutilização de conexões ao banco de dados
    private var connection: Connection? // Conexão única ao banco de dados
    static let sharedInstance = CommonUtils() // Singleton para acessar esta classe em toda a aplicação
    
    private init() {
        // Construtor privado para implementar o padrão Singleton
    }
    
    // Método para inicializar e retornar um pool de conexões ao banco de dados
    private func getConnectionPool(characterSet: String? = nil) throws -> ConnectionPool {
        if let pool = pool {
            return pool // Retorna o pool existente se já estiver inicializado
        }
        
        do {
            // Localiza o arquivo connection.json e carrega os dados de configuração
            let connectionFile = #file.replacingOccurrences(of: "Utils.swift", with: "connection.json")
            let data = Data(referencing: try NSData(contentsOfFile: connectionFile)) // Lê o arquivo JSON
            let json = try JSONSerialization.jsonObject(with: data)
            
            if let dictionary = json as? [String: String] {
                // Lê as informações do JSON
                let host = dictionary["host"]
                let user = dictionary["user"]
                let password = dictionary["password"]
                let database = dictionary["database"]
                
                var port: Int? = nil
                if let portString = dictionary["port"] {
                    port = Int(portString) // Converte a porta para inteiro, se disponível
                }
                
                let randomBinary = arc4random_uniform(2) // Gera um valor aleatório entre 0 e 1
                let poolOptions = ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 1) // Configurações do pool
                
                if characterSet != nil || randomBinary == 0 {
                    // Cria o pool de conexões usando os parâmetros fornecidos
                    pool = MySQLConnection.createPool(host: host,
                                                      user: user,
                                                      password: password,
                                                      database: database,
                                                      port: port,
                                                      characterSet: characterSet,
                                                      connectionTimeout: 10000,
                                                      poolOptions: poolOptions)
                } else {
                    // Alternativamente, constrói a URL de conexão
                    var url = "mysql://"
                    if let username = user, let password = password {
                        url += "\(username):\(password)@"
                    }
                    
                    url += host ?? "localhost"
                    
                    if let port = port {
                        url += ":\(port)"
                    }
                    
                    if let database = database {
                        url += "/\(database)"
                    }
                    
                    if let url = URL(string: url) {
                        pool = MySQLConnection.createPool(url: url, connectionTimeout: 10000, poolOptions: poolOptions)
                    } else {
                        pool = nil
                        print("Invalid URL: \(url)")
                    }
                }
            } else {
                pool = nil
                print("Invalid JSON: \(json)")
            }
        } catch {
            print("Error reading connection.json")
            pool = nil
        }
        
        return pool!
    }
    
    // Obtém ou inicializa uma conexão com o banco de dados
    func getConnection() -> Connection? {
        if let connection = connection {
            return connection
        }
        
        self.connection = nil
        
        do {
            try getConnectionPool().getConnection { connection, error in
                guard let connection = connection else {
                    // Trata erro ao conectar no banco de dados
                    print("Erro ao conectar no banco: \(error?.localizedDescription ?? "Erro desconhecido")")
                    return
                }
                self.connection = connection
                print("Conectado ao banco")
            }
            
            return connection
        } catch {
            return nil
        }
    }
    
    // Cria uma tabela no banco de dados
    func criaTabela(_ tabela: Table) {
        let thread = DispatchGroup()
        thread.enter()
        guard let con = getConnection() else {
            print("Sem conexão")
            return
        }
        
        tabela.create(connection: con) { result in
            if !result.success {
                print("Falha ao criar tabela: \(tabela.nameInQuery)")
            }
            thread.leave()
        }
        
        thread.wait() // Aguarda o término da operação
    }
    
    // Executa uma query genérica no banco de dados
    func executaQuery(_ query: Query) {
        let thread = DispatchGroup()
        thread.enter()
        if let connection = getConnection() {
            connection.execute(query: query) { result in
                var nomeQuery = String(describing: type(of: query))
                if nomeQuery == "Raw" {
                    nomeQuery = String(describing: query.self).split(separator: "\"")[1].split(separator: "")[0].capitalized
                }
                if let erro = result.asError {
                    print("\(nomeQuery), Falha de execução: \(erro)")
                }
                thread.leave()
            }
        } else {
            print("Sem conexão")
            thread.leave()
        }
        thread.wait() // Aguarda o término da operação
    }
    
    // Executa uma consulta SELECT e retorna os resultados
    func executaSelect(_ query: Select, aoFinal: @escaping ([[Any?]]?) -> ()) {
        let thread = DispatchGroup()
        thread.enter()
        
        var registros = [[Any?]]()
        
        if let connection = getConnection() {
            connection.execute(query: query) { result in
                guard let dados = result.asResultSet else {
                    print("Não houve resultado da consulta")
                    thread.leave()
                    return
                }
                
                dados.forEach { linha, error in
                    if let _linha = linha {
                        var colunas: [Any?] = [Any?]()
                        _linha.forEach { atributo in
                            colunas.append(atributo)
                        }
                        registros.append(colunas)
                    } else {
                        thread.leave()
                    }
                }
            }
        } else {
            print("Sem conexão")
            thread.leave()
        }
        
        thread.wait()
        aoFinal(registros) // Retorna os resultados ao final da execução
    }

    // Remove uma tabela do banco de dados
    func removeTabela(_ tabela: Table) {
        executaQuery(tabela.drop())
    }
}

