import Foundation

class Score {
    var date : Date
    var scoreJoueurs : Array<Joueur> = Array()
    init(date:Date,scoreJoueurs:Array<Joueur>) {
        self.date = date
        self.scoreJoueurs = scoreJoueurs
    }
}

