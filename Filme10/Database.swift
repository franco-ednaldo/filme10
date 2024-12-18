import Foundation
import SwiftKuery

class Filmes: Table {
    let tableName: String = "filme"
    let idFilme = Column("idFilme", Int32.self,  autoIncrement: true, primaryKey: true, notNull: true)
    let titulo = Column("titulo", String.self, notNull: true)
    let genero = Column("genero", String.self, notNull: true)
    let origem = Column("origem", String.self, notNull: true)
    let duracao = Column("duracao", Int32.self, notNull: true)
    let ano = Column("ano", Int32.self, notNull: true)
    let capa = Column("capa", String.self, notNull: true)
    let trailer = Column("trailer", String.self, notNull: true)
}

class Elencos: Table {
    let tableName: String = "elenco"
    let idElenco = Column("idElenco", Int32.self,  autoIncrement: true, primaryKey: true, notNull: true)
    let ator = Column("ator", String.self, notNull: true)
    let idade = Column("idade", Int32.self, notNull: true)
    let nacionalidade = Column("nacionalidade", String.self, notNull: true)
    let filme_idFilme = Column("filme_idFilme", String.self, notNull: true)
}
