//
//  ViewController.swift
//  Apple Newton’s Cradle Full Application
//
//  Created by Pawel Bednarczyk on 19.02.2016.
//  Copyright © 2016 Pawel Bednarczyk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var newtonsCradle: NewtonsCradle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNewtonsCradles(self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    func showNewtonsCradles(width: CGFloat, height: CGFloat) {
        
        // Let's create an instance of our UIKit Dynamics based Newton's Cradle. Try adding more colors to the array to increase the number of balls in the device.
        newtonsCradle = NewtonsCradle(colors: [
            [#Color(colorLiteralRed: 0.8779790997505188, green: 0.3812967836856842, blue: 0.5770481824874878, alpha: 1)#],
            [#Color(colorLiteralRed: 0.2202886641025543, green: 0.7022308707237244, blue: 0.9593387842178345, alpha: 1)#],
            [#Color(colorLiteralRed: 0.9166661500930786, green: 0.4121252298355103, blue: 0.2839399874210358, alpha: 1)#],
            [#Color(colorLiteralRed: 0.521954357624054, green: 0.7994346618652344, blue: 0.3460423350334167, alpha: 1)#]
            ], width: Int(width), height: Int(height))
        
        // Size and spacing
        // Try changing the size and spacing of the balls and see how that changes the device.
        // What happens if you make ballPadding a negative number?
        newtonsCradle.ballSize = CGSize(width: 60, height: 60)
        newtonsCradle.ballPadding = 0.2
        
        // Behavior
        // Adjust elasticity and resistance to change how the balls react to eachother.
        newtonsCradle.itemBehavior.elasticity = 1.0
        newtonsCradle.itemBehavior.resistance = 0.2
        
        // Shape and rotation
        // How does Newton's Cradle look if we use squares instead of circles and allow them to rotate?
        newtonsCradle.useSquaresInsteadOfBalls = false
        newtonsCradle.itemBehavior.allowsRotation = false
        
        // Gravity
        // Change the angle and/or magnitude of gravity to see what Newton's Device might look like in another world.
        newtonsCradle.gravityBehavior.angle = CGFloat(M_PI_2)
        newtonsCradle.gravityBehavior.magnitude = 1.0
        
        // Attachment
        // What happens if you change length of the attachment behaviors to different values?
        for attachmentBehavior in newtonsCradle.attachmentBehaviors {
            attachmentBehavior.length = 100
        }
        
        view.addSubview(newtonsCradle)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        showNewtonsCradles(size.width, height: size.height)
    }
    
}

