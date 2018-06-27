//
//  ViewController.swift
//  Puissance4
//
//  Copyright © 2018 Camille Guinaudeau. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var scores : [Score] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        //On remplit le tableau de scores avec tout les dictionnaires de la plist avec la date en clé
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
        tableView.delegate = self
        tableView.dataSource = self as UITableViewDataSource
        let path = getFilePath(nomFichier: "scores", typeFichier: "plist")
        let dic = NSDictionary(contentsOfFile: path)
        for (key, value) in dic! {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let laDate = dateFormatter.date(from:key as! String)
            var scoreJoueursDelaDate : Array<Joueur> = Array()
            for (key2, value2) in (value as? NSDictionary)! {
                scoreJoueursDelaDate.append(Joueur(nom: key2 as! String, score: value2 as! Int))
            }
            print(scoreJoueursDelaDate)
            scores.append(Score(date:laDate!, scoreJoueurs:scoreJoueursDelaDate))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(scores[indexPath.row].date)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        //
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        return scores.count
    }
    
    func getFilePath(nomFichier: String, typeFichier: String) -> String {
        
        // Initialisation de la variable writePath qui contient le chemin vers le fichier situé dans le repertoire Documents
        var writePath = ""
        
        let directories =   NSSearchPathForDirectoriesInDomains(.documentDirectory,   FileManager.SearchPathDomainMask.userDomainMask, true)
        if let documents = directories.first {
            print(documents)
            writePath = documents.appending("/"+nomFichier+"."+typeFichier)
            print(writePath)
        }
        
        let fileManager = FileManager.default
        if (!fileManager.fileExists(atPath: writePath)) {
            // Initialisation de la variable sourcepath qui contient le chemin vers le fichier situé dans le repertoire Bundle
            let sourcepath = Bundle.main.path(forResource:nomFichier, ofType:typeFichier)
            print(sourcepath!)
            do {
                try fileManager.copyItem(atPath: sourcepath!, toPath: writePath)
            }
            catch {
                print("Erreur au moment de la copie")
            }
        }
        return writePath
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Pour chaque dictionnaire, le titre de la cell est la date, et le contenu le nom du joueur et le score
        let cellIdentifier = "cellule"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let now = scores[indexPath.row].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.textLabel?.text = String(describing: dateFormatter.string(from: now))
        var retour=""
        for joueur in scores[indexPath.row].scoreJoueurs {
            retour+=joueur.description
        }
        print(retour)
        cell.detailTextLabel?.text = retour
        return cell
    }
    
}

