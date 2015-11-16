//
//  ViewController.swift
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
//  All the interesting stuff happens over in the InteractiveTransition class.
//  Here we just have outlets for the button and the button's action.
//  The only slightly interesting thing in here is the use of a IBInspectable
//  as part of adjusting the status bar to make sure it's visible.

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var button: UIButton!
	@IBInspectable var lightBackground: Bool = true

	override func viewDidLoad() {
		super.viewDidLoad()
		setNeedsStatusBarAppearanceUpdate()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		if lightBackground {
			return .Default
		} else {
			return .LightContent
		}
	}

	@IBAction func buttonTapped(sender:UIButton) {
		self.navigationController?.popViewControllerAnimated(true)
	}

}

