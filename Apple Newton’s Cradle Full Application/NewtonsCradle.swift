//
//  NewtonsCradle.swift
//  Apple Newton’s Cradle Full Application
//
//  Created by Pawel Bednarczyk on 19.02.2016.
//  Copyright © 2016 Pawel Bednarczyk. All rights reserved.
//

import UIKit

public class NewtonsCradle: UIView {
    
    private let colors: [UIColor]
    private var balls: [UIView] = []
    
    private var animator: UIDynamicAnimator?
    private var ballsToAttachmentBehaviors: [UIView:UIAttachmentBehavior] = [:]
    private var snapBehavior: UISnapBehavior?
    
    public let collisionBehavior: UICollisionBehavior
    public let gravityBehavior: UIGravityBehavior
    public let itemBehavior: UIDynamicItemBehavior
    
    public init(colors: [UIColor], width: Int, height: Int) {
        self.colors = colors
        collisionBehavior = UICollisionBehavior(items: [])
        gravityBehavior = UIGravityBehavior(items: [])
        itemBehavior = UIDynamicItemBehavior(items: [])
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        backgroundColor = UIColor.whiteColor()
        
        animator = UIDynamicAnimator(referenceView: self)
        animator?.addBehavior(collisionBehavior)
        animator?.addBehavior(gravityBehavior)
        animator?.addBehavior(itemBehavior)
        
        createBallViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        for ball in balls {
            ball.removeObserver(self, forKeyPath: "center")
        }
    }
    
    // MARK: Ball Views
    
    func createBallViews() {
        for color in colors {
            let ball = UIView(frame: CGRect.zero)
            
            // Observe the center point of the ball view to draw the attachment behavior.
            ball.addObserver(self, forKeyPath: "center", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
            
            // Make the ball view round and set the background
            ball.backgroundColor = color
            
            // Add the balls as a subview before we add it to any UIDynamicBehaviors.
            addSubview(ball)
            balls.append(ball)
            
            // Layout the balls based on the ballSize and ballPadding.
            layoutBalls()
        }
    }
    
    // MARK: Properties
    
    public var attachmentBehaviors:[UIAttachmentBehavior] {
        get {
            var attachmentBehaviors: [UIAttachmentBehavior] = []
            for ball in balls {
                guard let attachmentBehavior = ballsToAttachmentBehaviors[ball] else { fatalError("Can't find attachment behavior for \(ball)") }
                attachmentBehaviors.append(attachmentBehavior)
            }
            return attachmentBehaviors
        }
    }
    
    public var useSquaresInsteadOfBalls:Bool = false {
        didSet {
            for ball in balls {
                if useSquaresInsteadOfBalls {
                    ball.layer.cornerRadius = 0
                }
                else {
                    ball.layer.cornerRadius = ball.bounds.width / 2.0
                }
            }
        }
    }
    
    public var ballSize: CGSize = CGSize(width: 50, height: 50) {
        didSet {
            layoutBalls()
        }
    }
    
    public var ballPadding: Double = 0.0 {
        didSet {
            layoutBalls()
        }
    }
    
    // MARK: Ball Layout
    
    private func layoutBalls() {
        let requiredWidth = CGFloat(balls.count) * (ballSize.width + CGFloat(ballPadding))
        for (index, ball) in balls.enumerate() {
            // Remove any attachment behavior that already exists.
            if let attachmentBehavior = ballsToAttachmentBehaviors[ball] {
                animator?.removeBehavior(attachmentBehavior)
            }
            
            // Remove the ball from the appropriate behaviors before update its frame.
            collisionBehavior.removeItem(ball)
            gravityBehavior.removeItem(ball)
            itemBehavior.removeItem(ball)
            
            // Determine the horizontal position of the ball based on the number of balls.
            let ballXOrigin = ((bounds.width - requiredWidth) / 2.0) + (CGFloat(index) * (ballSize.width + CGFloat(ballPadding)))
            ball.frame = CGRect(x: ballXOrigin, y: bounds.midY, width: ballSize.width, height: ballSize.height)
            
            // Create the attachment behavior.
            let attachmentBehavior = UIAttachmentBehavior(item: ball, attachedToAnchor: CGPoint(x: ball.frame.midX, y: bounds.midY - 50))
            ballsToAttachmentBehaviors[ball] = attachmentBehavior
            animator?.addBehavior(attachmentBehavior)
            
            // Add the collision, gravity and item behaviors.
            collisionBehavior.addItem(ball)
            gravityBehavior.addItem(ball)
            itemBehavior.addItem(ball)
        }
    }
    
    // MARK: Touch Handling
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(superview)
            for ball in balls {
                if (CGRectContainsPoint(ball.frame, touchLocation)) {
                    snapBehavior = UISnapBehavior(item: ball, snapToPoint: touchLocation)
                    animator?.addBehavior(snapBehavior!)
                }
            }
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(superview)
            if let snapBehavior = snapBehavior {
                snapBehavior.snapPoint = touchLocation
            }
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let snapBehavior = snapBehavior {
            animator?.removeBehavior(snapBehavior)
        }
        snapBehavior = nil
    }
    
    // MARK: KVO
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "center") {
            setNeedsDisplay()
        }
    }
    
    // MARK: Drawing
    
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        for ball in balls {
            guard let attachmentBehavior = ballsToAttachmentBehaviors[ball] else { fatalError("Can't find attachment behavior for \(ball)") }
            let anchorPoint = attachmentBehavior.anchorPoint
            
            CGContextMoveToPoint(context, anchorPoint.x, anchorPoint.y)
            CGContextAddLineToPoint(context, ball.center.x, ball.center.y)
            CGContextSetStrokeColorWithColor(context, UIColor.darkGrayColor().CGColor)
            CGContextSetLineWidth(context, 4.0)
            CGContextStrokePath(context)
            
            let attachmentDotWidth:CGFloat = 10.0
            let attachmentDotOrigin = CGPoint(x: anchorPoint.x - (attachmentDotWidth / 2), y: anchorPoint.y - (attachmentDotWidth / 2))
            let attachmentDotRect = CGRect(x: attachmentDotOrigin.x, y: attachmentDotOrigin.y, width: attachmentDotWidth, height: attachmentDotWidth)
            
            CGContextSetFillColorWithColor(context, UIColor.darkGrayColor().CGColor)
            CGContextFillEllipseInRect(context, attachmentDotRect)
        }
        
        //        CGContextRestoreGState(context)
    }
}

