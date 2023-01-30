//
//  DetailNewsViewController.swift
//  NewsApp
//
//  Created by bjit on 15/1/23.
//

import UIKit

class DetailNewsViewController: UIViewController {
    
    var desc = ""
    var content = ""
    var img = ""
    var url = ""
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var largeImgView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        desLabel.text = desc
        largeImgView.sd_setImage(with: URL(string: img))
        contentLabel.text = content
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.DetailToNewsView {
            let destinationVC = segue.destination as! WKWebViewViewController
            destinationVC.url = url
        }
    }

    @IBAction func seeMoreBtn(_ sender: Any) {
        performSegue(withIdentifier: Identifier.DetailToNewsView, sender: nil)
    }
}
