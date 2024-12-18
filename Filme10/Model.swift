import Foundation

struct Filme {
    var idFilme: Int
    var titulo: String
    var genero: String
    var origem: String
    var duracao: Int
    var ano: Int
    var capa: String
    var trailer: String
    var colunas: [Any] { [idFilme, titulo, genero, origem, duracao, ano, capa, trailer] }
}

struct Elenco {
    var idElenco: Int
    var ator: String
    var idade: Int
    var nacionalidade: String
    var filme: Filme
    var colunas: [Any] { [idElenco, ator, idade, nacionalidade, filme.idFilme] }
}
