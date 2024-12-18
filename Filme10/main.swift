//
//  main.swift
//  Filme10
//
//  Created by Ednaldo Franco on 18/12/24.
//

import Foundation
import SwiftKuery



//let utils = CommonUtils.sharedInstance
//
//let filmes = Filmes ()
//utils.criaTabela (filmes)
//print("Tabela Filme Criada")
//
//let elencos = Elencos()
//_ = elencos.foreignKey(elencos.filme_idFilme, references: filmes.idFilme)
//utils.criaTabela (elencos)
//
//print("Tabela Elenco Criada")
//
//let listaFilmes = [
//    Filme (idFilme: 1, titulo: "Filme A", genero: "Herois", origem: "EUA", duracao: 2, ano:2023, capa: "image.jpg", trailer: "video.mp4"),
//    Filme (idFilme: 2, titulo: "Filme B", genero: "Herois", origem: "EUA", duracao: 2, ano: 2023, capa: "image.jpg", trailer: "video.mp4"),
//    Filme (idFilme: 3, titulo: "Filme C", genero: "Herois", origem: "EUA", duracao: 2, ano: 2023, capa: "image.jpg", trailer: "video.mp4")
//]
//utils.executaQuery (Insert(into: Filmes (), rows: listaFilmes.map {$0.colunas}))
//
//print("Os registros de Filmes foram inseridos")
//
//let listaElenco = [
//    Elenco (idElenco: 1, ator: "Felipe", idade: 25, nacionalidade: "Brasileiro", filme: listaFilmes[0]),
//    Elenco (idElenco: 2, ator: "Ana", idade: 25, nacionalidade: "Brasileiro", filme: listaFilmes [1]),
//    Elenco (idElenco: 3, ator: "Maria", idade: 25, nacionalidade: "Brasileiro", filme:  listaFilmes [2]),
//    Elenco (idElenco: 4, ator: "Robert", idade: 25, nacionalidade: "Brasileiro", filme: listaFilmes [0])
//]
//utils.executaQuery (Insert(into: Elencos (), rows: listaElenco.map {$0.colunas}))
//print("Os registros de Elencos foram inseridos")
