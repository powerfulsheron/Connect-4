//
//  ViewController.swift
//  Puissance4
//
//  Copyright © 2018 Camille Guinaudeau. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController{

    // Recuperation des user defaults pour les réglages
    let defaults = UserDefaults.standard
    
    // Variables des reglages
    var isMusique:Bool = true
    var isEffect:Bool = true
    
    // Noms joueurs
    var nomJoueurJaune = "Joueur Jaune"
    var nomJoueurRouge = "Joueur Rouge"
    
    // Images
    var pionVide : UIImage = UIImage(named:"pionVide.png")!
    var pionRouge : UIImage = UIImage(named:"pionRouge.png")!
    var pionJaune : UIImage = UIImage(named:"pionJaune.png")!
    
    // Variables d'instance
    var joueurCourant : Bool = true;
    var nbCaseLibres : Int = 42
    
    // Pour les fichiers sons
    var player: AVAudioPlayer?
    var player2: AVAudioPlayer?
    var player3: AVAudioPlayer?
    
    var indice_case_courante : Int = -1
    
    //Function qui gère la gagne
    func alertGagne(pionJoueurCourant:UIImage){
        var joueurGagnant="";
        if(pionJoueurCourant==pionJaune){
            joueurGagnant=nomJoueurJaune;
        }else{
            joueurGagnant=nomJoueurRouge;
        }
        // On va chercher le dictionnaire dans la plist et on insert or update avec la date du jour en clé.
        // Et on insert or update le nom du joueur.
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateNow = dateFormatter.string(from: date)
        print(dateNow)
        let path = getFilePath(nomFichier: "scores", typeFichier: "plist")
        let dicOrigin = NSDictionary(contentsOfFile: path) as! NSDictionary
        let dic:NSMutableDictionary = dicOrigin.mutableCopy() as! NSMutableDictionary
        if (dicOrigin.object(forKey: dateNow) != nil) {
            let dateDic = dic.value(forKey: dateNow) as! NSMutableDictionary
            if (dateDic.object(forKey: joueurGagnant) != nil) {
                let value = dateDic[joueurGagnant] as! Int
                dateDic[joueurGagnant]=value+1
            }else{
                dateDic.setValue(1, forKey: joueurGagnant)
            }
        }else{
            let scoreDic: [String: Int] = [joueurGagnant : 1]
            dic.setValue(scoreDic, forKey: dateNow)
        }
        _ = (dic).write(toFile: path, atomically: true)
        
        // Affichage de l'alerte
        let alert = UIAlertController(title: "Bravo !", message:joueurGagnant+" à gagné", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.reinitialize();
        }))
        self.present(alert, animated: true, completion: nil);
    }
    
    // Gestion de l'interface graphique - plateau
    @IBOutlet var caseOutlets: [UIImageView]!
    var taps: [UITapGestureRecognizer] = []
    @IBOutlet weak var labelJoueur: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isMusique = (defaults.bool(forKey: "isMusique"))
        isEffect = (defaults.bool(forKey: "isEffect"))
        if(defaults.integer(forKey: "backgroundColor")==1){
            self.view.backgroundColor = UIColor.black
        }else if(defaults.integer(forKey: "backgroundColor")==2){
            self.view.backgroundColor = UIColor.gray
        }else{
            self.view.backgroundColor = UIColor.white
        }
        if(defaults.integer(forKey: "pionType")==1){
            pionRouge = UIImage(named:"falloutRouge")!
            pionJaune = UIImage(named:"falloutJaune")!
        }
        // Création des objets de type UITapGestureRecognizer
        for i in 0...caseOutlets.count-1 {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            caseOutlets[i].isUserInteractionEnabled = true
            caseOutlets[i].addGestureRecognizer(tap)
            taps.append(tap)
        }
        
        // Remplissage du plateau
        for i in 0...caseOutlets.count-1 {
            caseOutlets[i].image = pionVide
        }
        

        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Connect 4", message: "Saisissez les noms des joueurs", preferredStyle: .alert)
            alert.addTextField { (joueur1) in
                joueur1.text = self.nomJoueurJaune;
            }
            alert.addTextField { (joueur2) in
                joueur2.text = self.nomJoueurRouge;
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                self.nomJoueurJaune = (alert?.textFields![0].text)!;
                self.nomJoueurRouge = (alert?.textFields![1].text)!;
                self.updateLabelJoueur(joueurCourant: true);
            }))
            self.present(alert, animated: true, completion: nil)
        }
        if(isMusique){
            let soundFilePath = Bundle.main.path(forResource: "wii", ofType: "mp3")
            let soundFileURL = URL(fileURLWithPath: soundFilePath!)
            do {
                player = try AVAudioPlayer(contentsOf: soundFileURL)
                player?.play()
                player?.numberOfLoops = -1 //infinite
            } catch {
                // couldn't load file :(
            }
        }
    }
    
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        let soundFilePath = Bundle.main.path(forResource: "bat", ofType: "wav")
        let soundFileURL = URL(fileURLWithPath: soundFilePath!)
        let indice_case_courante : Int = taps.index(of: sender)! as Int
        let indiceCaseLibre = premierIndiceLibre(indice:indice_case_courante);
        if(nbCaseLibres > 0 && indiceCaseLibre != 42){
            if(isEffect){
                do {
                    player2 = try AVAudioPlayer(contentsOf: soundFileURL)
                    player2?.play()
                } catch {
                    // couldn't load file :(
                }
            }
            if(joueurCourant){
                caseOutlets[indiceCaseLibre].image=pionJaune;
                gagne(indice: indiceCaseLibre, pionJoueurCourant: pionJaune);
            }else{
                caseOutlets[indiceCaseLibre].image=pionRouge;
                gagne(indice: indiceCaseLibre, pionJoueurCourant: pionRouge);
            }
            joueurCourant = !joueurCourant;
            updateLabelJoueur(joueurCourant: joueurCourant);
            nbCaseLibres-=1;
        }
        if(nbCaseLibres==0){
            let alert = UIAlertController(title: "Egalité", message:"Réinitialisation du jeu", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.reinitialize();
            }))
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func premierIndiceLibre(indice: Int) -> Int{
        let retour = 42;
        let limite : Int = (indice/6);
        for i in limite*6..<((limite+1)*6) {
            if(caseOutlets[i].image==pionVide){
                return i;
            }
        }
        return retour;
    }
    
    func reinitialize(){
        updateLabelJoueur(joueurCourant:true);
        for i in 0...caseOutlets.count-1 {
            caseOutlets[i].image = pionVide
        }
        nbCaseLibres=42;
    }
    
    func updateLabelJoueur(joueurCourant:Bool){
        if(joueurCourant){
            labelJoueur.text=nomJoueurJaune;
            labelJoueur.textColor=UIColor.orange;
        }else{
            labelJoueur.text=nomJoueurRouge;
            labelJoueur.textColor=UIColor.red
        }
    }
    // Fonction qui regarde pour un indice si le joueur gagne 
    func gagne(indice:Int, pionJoueurCourant:UIImage){
        print(indice)
        // Dans l'orde : Horizontal, Vertical, Diagonal(Absysse x)asc, Diagonal(Absysse y)asc, Diagonal(Absysse x)desc, Diagonal(Absysse y)desc
        if(
            (checkLigne(limiteDebut: indice%6, limiteFin: (indice%6)+36, pas: 6, pionJoueurCourant: pionJoueurCourant))
                
            || (checkLigne(limiteDebut: (indice/6)*6, limiteFin: (((indice/6)+1)*6)-1, pas: 1, pionJoueurCourant: pionJoueurCourant))
            
            || (checkLigne(limiteDebut: (indice%7), limiteFin: (7*(5-(indice%7)))+indice%7, pas: 7, pionJoueurCourant: pionJoueurCourant))
            
            || (checkLigne(limiteDebut: (indice%7)+((6-(indice%7))*7), limiteFin: (((indice%7)-1)*7)+((indice%7)+((6-(indice%7))*7)), pas: 7, pionJoueurCourant: pionJoueurCourant))
            
            || (checkLigne(limiteDebut: (indice%5), limiteFin: (indice%5)*6, pas: 5, pionJoueurCourant: pionJoueurCourant))
            
            || (checkLigne(limiteDebut: (5+((indice%5)*5))+indice%5, limiteFin: 35+(indice%5), pas: 5, pionJoueurCourant: pionJoueurCourant))
            
            ){
            
            if(isEffect){
                let soundFilePath = Bundle.main.path(forResource: "ko", ofType: "wav")
                let soundFileURL = URL(fileURLWithPath: soundFilePath!)
                do {
                    player3 = try AVAudioPlayer(contentsOf: soundFileURL)
                    player3?.play()
                } catch {
                    // couldn't load file :(
                }
            }
            alertGagne(pionJoueurCourant: pionJoueurCourant);
        }
    }
    
    func checkLigne(limiteDebut:Int,limiteFin:Int,pas:Int,pionJoueurCourant:UIImage)-> Bool{
        var alignes = 0;
        for i in stride(from:limiteDebut, to:limiteFin, by:pas) {
            if(caseOutlets[i].image==pionJoueurCourant){
                alignes+=1;
            }else{
                alignes=0;
            }
            if(alignes==4){
                return true;
            }
           
        }
        return false;
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
}
