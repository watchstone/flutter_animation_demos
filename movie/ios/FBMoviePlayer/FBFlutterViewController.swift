//
//  FBFlutterViewController.swift
//  FBMoviePlayer
//
//  Created by chongling.liu on 2021/5/14.
//

import Flutter
import Foundation
import FlutterPluginRegistrant

class FBFlutterViewController: FlutterViewController {
    
    private var channel: FlutterMethodChannel?
    
    init(withEntrypoint entryPoint: String?) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let newEngine = appDelegate.engineGroup.makeEngine(withEntrypoint: entryPoint, libraryURI: nil)
        super.init(engine: newEngine, nibName: nil, bundle: nil)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(withEntrypoint: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GeneratedPluginRegistrant.register(with: self.pluginRegistry())
        channel = FlutterMethodChannel(
            name: "fbmovie.com/tab_switch", binaryMessenger: self.engine!.binaryMessenger)
        channel!.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
          if call.method == "showTab" {
            self?.showTab()
          } else if call.method == "hideTab" {
            self?.hideTab()
          } else {
            result(FlutterMethodNotImplemented)
          }
        }
    }
    
    func showTab() {
        self.parent?.tabBarController?.tabBar.isHidden = false
    }
    
    func hideTab() {
        self.parent?.tabBarController?.tabBar.isHidden = true
    }
    
}
