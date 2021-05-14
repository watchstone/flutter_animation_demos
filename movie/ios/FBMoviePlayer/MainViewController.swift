//
//  ViewController.swift
//  FBMoviePlayer
//
//  Created by chongling.liu on 2021/5/12.
//

import UIKit

class MainViewController: UIViewController {
    
    private lazy var subFlutterVC: FBFlutterViewController = FBFlutterViewController(withEntrypoint: nil)
    
    override func viewDidLoad() {
        addChild(subFlutterVC)
        let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
        subFlutterVC.view.frame = safeFrame
        self.view.addSubview(subFlutterVC.view)
        subFlutterVC.didMove(toParent: self)
    }
    
}

