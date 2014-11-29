//
//  ViewController.swift
//  ExampleOverlayDrawerController
//
//  Created by Mark Miyashita on 11/28/14.
//  Copyright (c) 2014 Mark Miyashita. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override init() {
    super.init()
    title = "ViewController"
    view.backgroundColor = .whiteColor()
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Show", style: .Plain, target: self, action: "showNavigationDrawer:")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.restorationIdentifier = "ViewControllerRestorationKey"
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func showNavigationDrawer(sender: UIButton) {
    println("pressed")
    self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
  }

}

