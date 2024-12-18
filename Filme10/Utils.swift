import Foundation
import SwiftKuery
import SwiftKueryMySQL

class CommonUtils {
    private var pool: ConnectionPool?
    private var connection: Connection?
    static let sharedInstance = CommonUtils()
    
    private init() {
        
    }
    
    private func getConnectionPool(characterSet: String? = nil) throws -> ConnectionPool {
        if let pool = pool {
            return pool
        }
        
        do {
            let connectionFile = #file.replacingOccurrences(of: "Utils.swift", with: "connection.json")
            let data = Data(referencing: try NSData(contentsOfFile: connectionFile)) // le o arquivo json
            let json = try JSONSerialization.jsonObject(with: data)
            
            if let dictionary = json as? [String: String] {
                let host = dictionary["host"]
                let user = dictionary["user"]
                let password = dictionary["password"]
                let database = dictionary["database"]
                
                var port: Int? = nil
                if let portString = dictionary["port"] {
                    port = Int(portString)
                }
                let randomBinary = arc4random_uniform(2)
                let poolOptions = ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 1)
                
                if characterSet != nil || randomBinary == 0 {
                    pool = MySQLConnection.createPool(host: host,
                                                      user: user,
                                                      password: password,
                                                      database: database,
                                                      port: port,
                                                      characterSet: characterSet,
                                                      connectionTimeout: 10000,
                                                      poolOptions: poolOptions)
                } else {
                    // "mysql://username:password@host:port/database"
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
                print("Invalid json: \(json)")
            }
            
        } catch {
            print("Error reading connection.json")
            pool = nil
        }
        
        return pool!
    }
    
    
    func getConnection() -> Connection? {
        if let connection = connection {
            return connection
        }
        
        self.connection = nil
        
        do {
            try getConnectionPool().getConnection{connection, error in
                guard let connection = connection else {
                    guard let error else {
                        return print("Error ao connectar no banco \(error?.localizedDescription ?? "Erro desconhecido")")
                    }
                    return print("Error ao connectar no banco \(error.localizedDescription ?? "Erro desconhecido")")
                }
                self.connection = connection
                return print("Conectado ao banco")
            }
            
            return connection
        } catch {
            return nil
        }
        
    }
    
    func criaTabela(_ tabela:Table) {
        let thread = DispatchGroup()
        thread.enter()
        guard let con = getConnection() else {
            return print("Sem conexao")
        }
        
        tabela.create(connection: con) { result in
            if !result.success {
                print("Falha ao criar tabela: \(tabela.nameInQuery)")
            }
            thread.leave()
        }
        
        thread.wait()
    }
    
    func executaQuery(_ query: Query) {
        let thread = DispatchGroup()
        thread.enter()
        if let connection = getConnection() {
            connection.execute(query: query) {
                result in
                var nomeQuery = String(describing: type (of: query))
                if nomeQuery == "Raw" {
                    nomeQuery = String(describing: query.self).split(separator:"\"")[1].split(separator: "")[0].capitalized
                }
                if let erro = result.asError {
                    print("\(nomeQuery), Falha de execucao: \(erro)")
                }
                thread.leave()
            }
        } else {
            print("Sem conexao")
            thread.leave()
        }
        thread.wait()
    }
    
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
            print("Sem Conexão")
            thread.leave()
        }
        
        thread.wait()
        aoFinal(registros)
    }

    
    func removeTabela(_ tabela: Table) {
        executaQuery(tabela.drop())
    }
}
