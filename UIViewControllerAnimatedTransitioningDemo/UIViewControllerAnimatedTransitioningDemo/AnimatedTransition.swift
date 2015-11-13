//
//  AnimatedTransition.swift
//  UIViewControllerAnimatedTransitioningDemo
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
//
//  This class implements both the navigation controller delegate and the animated 
//  transitioning object. As a navigation controller delegate it supplies the itself
//  as the animated transitioning object. As the animated transitioning object it 
//  asks the associated view controllers for their animation duration and to execute
//  their animations.

import UIKit


class AnimatedTransition: NSObject, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {

	// MARK: UINavigationControllerDelegate
	// Just supply this object when asked for the animated transitioning object. 
	// This call does give the opportunity to create more complex logic on how 
	// to choose an animated transitioning object.
	func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self
	}

	// MARK: UIViewControllerAnimatedTransitioning
	// This app's design gives responsibility to the view controllers which
	// adopt the SelfAnimatedTransitioning protocol for supplying their 
	//  animation duration.
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {

		// In the case where we don't get a transition context, there is no
		// animation duration.
		guard let tc = transitionContext else {
			return 0.0
		}

		// Find the view controllers that conform to SelfAnimatedTransitioning.
		let fromVC = tc.viewControllerForKey(UITransitionContextFromViewControllerKey) as! SelfAnimatedTransitioning
		let toVC = tc.viewControllerForKey(UITransitionContextToViewControllerKey) as! SelfAnimatedTransitioning

		// Return the sum of the view controllers animation.
		return fromVC.leavingAnimaitonDuration + toVC.arrivingAnimationDuration
	}

	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

		// Find the view controllers that conform to SelfAnimatedTransitioning.
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! SelfAnimatedTransitioning
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! SelfAnimatedTransitioning

		// Tell the from view controller to animate, passing it a completion 
		// to tell the to controller to animate, which gets a completion to 
		// tell the transition context the transition is complete.
		fromVC.performLevaingAnimaitonInContainerView(transitionContext.containerView()!) { (finished: Bool) -> () in
			toVC.performArrivingAnimationInContainerView(transitionContext.containerView()!, completion: { (finished:Bool) -> () in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
			})
		}
	}

}