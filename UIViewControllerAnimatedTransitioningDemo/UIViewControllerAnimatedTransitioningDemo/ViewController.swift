//
//  ViewController.swift
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
//  This simple example demonstrates how a view controller can supply its own 
//  transitioning animation.

import UIKit

class ViewController: UIViewController, SelfAnimatedTransitioning {

	// How long should the animations last.
	var leavingAnimaitonDuration: NSTimeInterval { return 0.6 }
	var arrivingAnimationDuration: NSTimeInterval { return 0.6 }

	// The image that is animated.
	var car: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add a button to load the next view.
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "nextView")

		// Choose a random car color so we see that the view changes.
		var imageName = ""
		let dieRoll = Int(arc4random_uniform(4) + 1)
		switch dieRoll {
		case 1:
			imageName = "car_blue_1"
		case 2:
			imageName = "car_green_1"
		case 3:
			imageName = "car_red_1"
		default:
			imageName = "car_yellow_1"
		}

		// Add the car.
		car = UIImageView(image: UIImage(named: imageName))
		view.addSubview(car)

		// Move the car to the center of the view.
		car.center = view.center
	}

	// Load the next view. In this simplest of example programs, this will 
	// just load another copy of this same view controller.
	func nextView() {
		if let nextVC = storyboard?.instantiateViewControllerWithIdentifier("sand") {
			navigationController?.pushViewController(nextVC, animated: true)
		}
	}

	// Create the animation for arriving.
	func performArrivingAnimationInContainerView(containerView: UIView, completion: (Bool)->()) {

		// The transitioning context has a view where the animation should be drawn. 
		// So add this controller's view to that container.
		containerView.addSubview(self.view)

		// Our animation simply drives the car in from the bottom of the screen. 
		// Start by moving the car off screen.
		self.car.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height + (self.car.frame.size.height / 2.0))

		// Then animate it to the center of the view, using the passed in completion.
		UIView.animateWithDuration(arrivingAnimationDuration, animations: { () -> Void in
			self.car.center = self.view.center
			}, completion: completion)

		// Animations can be done in stages, with a completion passed to an 
		// UIView.animateWithDuration( , animations: , completion: ) call that starts
		// another animation. Make sure the last animation to finish calles the passed
		// in completion.
	}

	// Create the animation for leaving.
	func performLevaingAnimaitonInContainerView(containerView: UIView, completion: (Bool)->()) {

		// The transitioning context has a view where the animation should be drawn.
		// So add this controller's view to that container.
		containerView.addSubview(self.view)

		// Our animation simply drives the car off the top of the screen, and uses
		// the passed in completion.
		UIView.animateWithDuration(arrivingAnimationDuration, animations: { () -> Void in
			self.car.center = CGPoint(x: self.car.center.x, y: -(self.car.frame.size.height / 2.0))
			}, completion: completion)

		// Animations can be done in stages, with a completion passed to an
		// UIView.animateWithDuration( , animations: , completion: ) call that starts
		// another animation. Make sure the last animation to finish calles the passed
		// in completion.
	}

}

