//
//  GeminiControlLayer.swift
//  GeminiPlayer
//
//  Created by Eric on 6/7/23.
//

import UIKit

protocol GeminiControl {
    func play()
    func pause()
    func stop()
    func switching(source: String?)
}

class GeminiControlLayer: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
