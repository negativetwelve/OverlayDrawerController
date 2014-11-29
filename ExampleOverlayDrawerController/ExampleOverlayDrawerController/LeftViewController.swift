//
//  LeftViewController.swift
//  ExampleOverlayDrawerController
//
//  Created by Mark Miyashita on 11/28/14.
//  Copyright (c) 2014 Mark Miyashita. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController {
  
  override init() {
    super.init()
    title = "LeftViewController"
    view.backgroundColor = .blueColor()
    
    var subview = UIView(frame: CGRect(x: 80, y: 10, width: 100, height: 100))
    subview.backgroundColor = .orangeColor()
    self.view.addSubview(subview)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.restorationIdentifier = "LeftViewControllerRestorationKey"
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

