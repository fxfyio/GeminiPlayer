//
//  ViewController.swift
//  GeminiPlayer
//
//  Created by zc on 5/21/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let version = String(cString: av_version_info())
        let config = String(cString: avcodec_configuration())
        let license = String(cString: avcodec_license())
        print("FFmpeg version: \(version)")
        let label = UILabel()
        label.numberOfLines = 0
        label.frame = self.view.bounds
        label.textAlignment = .center
        label.text = version + "\n" + config + "\n" + license
        self.view.addSubview(label)
    }


}

