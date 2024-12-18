//
//  main.swift
//  Filme10
//
//  Created by Ednaldo Franco on 18/12/24.
//

import Foundation
import SwiftKuery

// Instância única da classe CommonUtils para gerenciamento de conexões e operações no banco
let utils = CommonUtils.sharedInstance

// Criação da tabela de filmes
let filmes = Filmes()
utils.criaTabela(filmes)
print("Tabela Filme Criada")

// Criação da tabela de elencos com chave estrangeira referenciando a tabela de filmes
let elencos = Elencos()
_ = elencos.foreignKey(elencos.filme_idFilme, references: filmes.idFilme)
utils.criaTabela(elencos)
print("Tabela Elenco Criada")

// Lista de filmes para inserção no banco de dados
let listaFilmes = [
    Filme(idFilme: 1, titulo: "Filme A", genero: "Herois", origem: "EUA", duracao: 2, ano: 2023, capa: "image.jpg", trailer: "video.mp4"),
    Filme(idFilme: 2, titulo: "Filme B", genero: "Herois", origem: "EUA", duracao: 2, ano: 2023, capa: "image.jpg", trailer: "video.mp4"),
    Filme(idFilme: 3, titulo: "Filme C", genero: "Herois", origem: "EUA", duracao: 2, ano: 2023, capa: "image.jpg", trailer: "video.mp4")
]

// Inserção de registros na tabela de filmes
utils.executaQuery(Insert(into: Filmes(), rows: listaFilmes.map { $0.colunas }))
print("Os registros de Filmes foram inseridos")

// Lista de elencos para inserção no banco de dados
let listaElenco = [
    Elenco(idElenco: 1, ator: "Felipe", idade: 25, nacionalidade: "Brasileiro", filme: listaFilmes[0]),
    Elenco(idElenco: 2, ator: "Ana", idade: 25, nacionalidade: "Brasileiro", filme: listaFilmes[1]),
    Elenco(idElenco: 3, ator: "Maria", idade: 25, nacionalidade: "Brasileiro", filme: listaFilmes[2]),
    Elenco(idElenco: 4, ator: "Robert", idade: 25, nacionalidade: "Brasileiro", filme: listaFilmes[0])
]

// Inserção de registros na tabela de elencos
utils.executaQuery(Insert(into: Elencos(), rows: listaElenco.map { $0.colunas }))
print("Os registros de Elencos foram inseridos")

// Atualização do nome e idade de um ator no elenco
utils.executaQuery(Update(elencos, set: [(elencos.ator, "Felipe Santos"), (elencos.idade, 29)], where: elencos.idElenco == 1))
print("Alterado o nome e idade do Felipe")

// Exclusão de um registro de elenco pelo ID
utils.executaQuery(Delete(from: elencos).where(elencos.idElenco == 4))
print("Ator excluído do banco - Robert")

// Função para realizar consultas no banco de dados e exibir os resultados
func consulta(_ select: Select) {
    let utils = CommonUtils.sharedInstance
    utils.executaSelect(select) { registros in
        guard let registros = registros else {
            return print("Sem registros")
        }
        registros.forEach { linha in
            linha.forEach { item in
                print("\(item ?? "")".fill(), terminator: " ") // Formatação de saída
            }
            print()
        }
    }
}

// Extensão para adicionar preenchimento a strings, facilitando o alinhamento na saída
public extension String {
    func fill(to: Int = 20) -> String {
        var saida = self
        if self.count < to {
            for _ in 0..<(to - self.count) {
                saida += " "
            }
        }
        return saida
    }
}

// Consulta para buscar os atores do elenco, títulos e anos dos filmes relacionados
consulta(
    Select(
        elencos.ator, // Nome do ator
        filmes.titulo, // Título do filme
        filmes.ano,    // Ano de lançamento do filme
        from: elencos
    )
    .join(filmes) // Junta a tabela de elencos com a de filmes
        .on(elencos.filme_idFilme == filmes.idFilme) // Condição de junção pelas chaves relacionadas
)
