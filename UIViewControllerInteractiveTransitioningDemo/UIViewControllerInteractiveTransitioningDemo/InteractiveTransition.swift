//
//  InteractiveTransition.swift
//  UIViewControllerInteractiveTransitioningDemo
//
//  Created by Sunny Fish LLC on 11/12/15.
//  This is free and unencumbered software released into the public domain.
//
//  Anyone is free to copy, modify, publish, use, compile, sell, or distribute
//  this software, either in source code form or as a compiled binary, for any
//  purpose, commercial or non-commercial, and by any means.
//
//  In jurisdictions that recognize copyright laws, the author or authors of
//  this software dedicate any and all copyright interest in the software to the
//  public domain. We make this dedication for the benefit of the public at
//  large and to the detriment of our heirs and successors. We intend this
//  dedication to be an overt act of relinquishment in perpetuity of all present
//  and future rights to this software under copyright law.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  This demonstrates how to use an object that complies with the
//  UIViewControllerInteractiveTransitioning protocol. We just use the Apple 
//  supplied UIPercentDrivenInteractiveTransition implementation of the protocol.
//	Maybe if we revisit this for a longer presentation, we can implement a 
//  custom transitioning object.
//
//  The transition is driven by a pan gesture recognizer, so we create an
//  interaction controller when we start handling the gesture recognizer.
//  The transition is to expand or shrink a circe from large enough to cover the
//  view to the size of a circular button, done with a CABasicAnimation.

import UIKit

class InteractiveTransition: NSObject, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {

	// The interaction controller.
	var interactionController: UIPercentDrivenInteractiveTransition?

	// The context for the transition.
	weak var transitionContext: UIViewControllerContextTransitioning?

	// The navigation controller. Set this in Interface Builder.
	@IBOutlet weak var navigationController: UINavigationController?

	// We remember the initial pan direction so we can decide to finish the 
	// transition or cancel the transition based on the final direction.
	var panDirection: CGFloat = 0

	// Install the gesture recognizer if we're hooked up to a navigation controller.
	override func awakeFromNib() {
		super.awakeFromNib()
		guard let nc = navigationController else {
			return
		}
		nc.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("panned:")))
	}

	// Handle the pan gesture recognizer.
	func panned(gestureRecognizer: UIPanGestureRecognizer) {

		// Make sure the navigation controller is hooked up.
		guard let nc = navigationController else {
			return
		}

		// Decide what to do based on the state of the recognizer.
		switch gestureRecognizer.state {
		case .Began:

			// In the beginning create the interaction transition for this pan.
			self.interactionController = UIPercentDrivenInteractiveTransition();

			// Save the direction.
			panDirection = gestureRecognizer.velocityInView(nc.view).x

			// Push or pop the view controller. In a more complex app you might ask the 
			// top view controller what to do, instead of assume it just wants to be popped
			// if there is another view controller under it.
			if nc.viewControllers.count > 1 {
				nc.popViewControllerAnimated(true)
			} else {
				nc.topViewController!.performSegueWithIdentifier("PushSegue", sender: nil)
			}
		case .Changed:

			// Get the percentage base on how far the pan has moved.
			let translation = gestureRecognizer.translationInView(nc.view)
			let completionProgress = abs(translation.x / CGRectGetWidth(nc.view.bounds))

			// Tell the interaction controller to update to that percentage.
			interactionController?.updateInteractiveTransition(completionProgress)
		case .Ended:

			// If the pan has reversed, the initial direction will be the opposite 
			// sign than the final direction. Multiplying two numbers of the same sign
			// will always result in a positive number, so the transition should
			// finish. With a negative result, one direction was the opposite of the
			// other, and we should cancel the transition.
			if (gestureRecognizer.velocityInView(nc.view).x * panDirection) > 0 {
				self.interactionController?.finishInteractiveTransition()
			} else {
				self.interactionController?.cancelInteractiveTransition()
			}

			// Either way, we're done and can let go of the interaction controller.
			self.interactionController = nil
		default:

			// All the other possible states mean the gesture is not active
			// so we can clean up.
			self.interactionController?.cancelInteractiveTransition()
			self.interactionController = nil
		}
	}

	// MARK: UINavigationControllerDelegate

	// Just supply the interactive transitioning object property, as it won't exist
	// when the pan gesture recognizer is inactive, so we will get a regular animated
	// transition. After this object starts handling a gesture recognizer there will 
	// be an interactive transitioning object, so the user will see the interactive
	// transition.
	func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return self.interactionController
	}

	// Just supply this object when asked for the animated transitioning object.
	// This call does give the opportunity to create more complex logic on how
	// to choose an animated transitioning object.
	func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self
	}


	// MARK: UIViewControllerAnimatedTransitioning

	// This object knows the transition is short and fixed length when not interactive.
	// When interactive, the UIPercentDrivenInteractiveTransition will prorate this value
	// based on how much animation is left when the animation is completed or canceled.
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.5
	}

	// Run the actual animation. We're masking out one view with
	// a growing or shrinking mask.
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

		// Save the transition context for later.
		self.transitionContext = transitionContext

		// Setup the screen elements to animate.
		let container = transitionContext.containerView()
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ViewController
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ViewController
		let button = fromVC.button;
		container!.addSubview(toVC.view)

		// Setup the big and small circle path for the animated mask.
		let circleMaskPathInitial = UIBezierPath(ovalInRect: button.frame)
		let extremePoint = CGPoint(x: button.center.x - 0.0, y: button.center.y - CGRectGetHeight(toVC.view.bounds))
		let radius = sqrt((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y))
		let circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(button.frame, -radius, -radius))

		// Add a mask layer.
		let maskLayer = CAShapeLayer ()
		maskLayer.path = circleMaskPathFinal.CGPath
		toVC.view.layer.mask = maskLayer;

		// Animate with a CABasicAnimation
		let maskLayerAnimation = CABasicAnimation(keyPath: "path")
		maskLayerAnimation.fromValue = circleMaskPathInitial.CGPath
		maskLayerAnimation.toValue = circleMaskPathFinal.CGPath
		maskLayerAnimation.duration = self.transitionDuration(transitionContext)
		maskLayerAnimation.delegate = self
		maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
	}

	// Here's a chance to clean up after the animations.
	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		guard let tc = transitionContext else {
			return
		}
		tc.completeTransition(!tc.transitionWasCancelled())
		tc.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
	}
}
