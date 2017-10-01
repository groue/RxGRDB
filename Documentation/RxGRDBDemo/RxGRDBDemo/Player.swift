import GRDB

// A player
struct Player: Codable {
    var id: Int64?
    var name: String
    var score: Int
}

// Define colums so that we can build GRDB requests
extension Player {
    enum Columns {
        static let name = Column("name")
        static let score = Column("score")
    }
}

// Adopt RowConvertible so that we can fetch players from the database.
// Implementation is automatically derived from Codable.
extension Player: RowConvertible { }

// Adopt MutablePersistable so that we can create/update/delete players in the database.
// Implementation is partially derived from Codable.
extension Player: MutablePersistable {
    static let databaseTableName = "players"
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// Support for player randomization
extension Player {
    private static let names = ["Arthur", "Anita", "Barbara", "Bernard", "Craig", "Chiara", "David", "Dean", "Éric", "Elena", "Fatima", "Frederik", "Gilbert", "Georgette", "Henriette", "Hassan", "Ignacio", "Irene", "Julie", "Jack", "Karl", "Kristel", "Louis", "Liz", "Masashi", "Mary", "Noam", "Nicole", "Ophelie", "Oleg", "Pascal", "Patricia", "Quentin", "Quinn", "Raoul", "Rachel", "Stephan", "Susie", "Tristan", "Tatiana", "Ursule", "Urbain", "Victor", "Violette", "Wilfried", "Wilhelmina", "Yvon", "Yann", "Zazie", "Zoé"]
    
    static func randomName() -> String {
        return names[Int(arc4random_uniform(UInt32(names.count)))]
    }
    
    static func randomScore() -> Int {
        return 10 * Int(arc4random_uniform(101))
    }
    
    static func randomizePlayers(_ db: Database) throws {
        if try fetchCount(db) == 0 {
            // Insert players
            for _ in 0..<8 {
                var player = Player(id: nil, name: randomName(), score: randomScore())
                try player.insert(db)
            }
        } else {
            // Insert a player
            if arc4random_uniform(2) == 0 {
                var player = Player(id: nil, name: randomName(), score: randomScore())
                try player.insert(db)
            }
            // Delete a player
            if arc4random_uniform(2) == 0 {
                if let player = try order(sql: "RANDOM()").fetchOne(db) {
                    try player.delete(db)
                }
            }
            // Update some players
            for player in try fetchAll(db) where arc4random_uniform(2) == 0 {
                var player = player
                player.score = randomScore()
                try player.update(db)
            }
        }
    }
}
