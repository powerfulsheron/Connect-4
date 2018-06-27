import Foundation

class Joueur {
    var nom : String
    var score : Int
    var description: String{
        return nom+" : "+String(score)+"    "
    }
    init(nom:String,score:Int) {
        self.nom = nom
        self.score = score
    }
}
