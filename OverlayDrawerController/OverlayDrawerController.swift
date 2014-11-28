//
//  OverlayDrawerController.swift
//  ExampleOverlayDrawerController
//
//  Created by Mark Miyashita on 11/28/14.
//  Copyright (c) 2014 Mark Miyashita. All rights reserved.
//

import UIKit

public enum DrawerSide: Int {
  case None
  case Left
  case Right
}

public enum DrawerOpenCenterInteractionMode: Int {
  case None
  case Full
  case NavigationBarOnly
}

private class DrawerCenterContainerView: UIView {
  private var openSide: DrawerSide = .None
  var centerInteractionMode: DrawerOpenCenterInteractionMode = .None
  
  private override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
    var hitView = super.hitTest(point, withEvent: event)
    
    if hitView != nil && self.openSide != .None {
      let navBar = self.navigationBarContainedWithinSubviewsOfView(self)
      
      if navBar != nil {
        let navBarFrame = navBar!.convertRect(navBar!.bounds, toView: self)
        if (self.centerInteractionMode == .NavigationBarOnly && CGRectContainsPoint(navBarFrame, point) == false) || (self.centerInteractionMode == .None) {
          hitView = nil;
        }
      }
    }
    
    return hitView
  }
  
  private func navigationBarContainedWithinSubviewsOfView(view: UIView) -> UINavigationBar? {
    var navBar: UINavigationBar?
    
    for subview in view.subviews as [UIView] {
      if view.isKindOfClass(UINavigationBar) {
        navBar = view as? UINavigationBar
        break
      } else {
        navBar = self.navigationBarContainedWithinSubviewsOfView(subview)
        if navBar != nil {
          break
        }
      }
    }
    
    return navBar
  }
}

public class OverlayDrawerController: UIViewController, UIGestureRecognizerDelegate {
  private var _centerViewController: UIViewController?
  private var _leftDrawerViewController: UIViewController?

  public var centerViewController: UIViewController? {
    get {
      return self._centerViewController
    }
    
    set {
      self.setCenterViewController(newValue, animated: false)
    }
  }

  public var leftDrawerViewController: UIViewController? {
    get {
      return self._leftDrawerViewController
    }
    
    set {
      self.setDrawerViewController(newValue, forSide: .Left)
    }
  }
  
  private lazy var childControllerContainerView: UIView = {
    let childContainerViewFrame = self.view.bounds
    let childControllerContainerView = UIView(frame: childContainerViewFrame)
    childControllerContainerView.backgroundColor = UIColor.clearColor()
    childControllerContainerView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    self.view.addSubview(childControllerContainerView)
    
    return childControllerContainerView
    }()
  
  private lazy var centerContainerView: DrawerCenterContainerView = {
    let centerFrame = self.childControllerContainerView.bounds
    
    let centerContainerView = DrawerCenterContainerView(frame: centerFrame)
    centerContainerView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    centerContainerView.backgroundColor = UIColor.clearColor()
    centerContainerView.openSide = self.openSide
    centerContainerView.centerInteractionMode = self.centerHiddenInteractionMode
    self.childControllerContainerView.addSubview(centerContainerView)
    
    return centerContainerView
    }()
  
  public private(set) var openSide: DrawerSide = .None
  
  public var centerHiddenInteractionMode: DrawerOpenCenterInteractionMode = .NavigationBarOnly {
    didSet {
      self.centerContainerView.centerInteractionMode = self.centerHiddenInteractionMode
    }
  }
  
  //
  // MARK: - Initializers
  //
  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  public init(centerViewController: UIViewController, leftDrawerViewController: UIViewController?) {
    super.init()
    
    self.centerViewController = centerViewController
    self.leftDrawerViewController = leftDrawerViewController
  }
  
  //
  // MARK: - Setters
  //
  private func setDrawerViewController(viewController: UIViewController?, forSide drawerSide: DrawerSide) {
    if drawerSide == .Left {
      self._leftDrawerViewController = viewController
    } else if drawerSide == .Right {
      // RightDrawerViewController
    }
  }
  
  //
  // MARK: - Updating the Center View Controller
  //
  private func setCenterViewController(centerViewController: UIViewController?, animated: Bool) {
    if self._centerViewController == centerViewController {
      return
    }
    
    if let oldCenterViewController = self._centerViewController {
      oldCenterViewController.willMoveToParentViewController(nil)
      
      if animated == false {
        oldCenterViewController.beginAppearanceTransition(false, animated: false)
      }
      
      oldCenterViewController.removeFromParentViewController()
      oldCenterViewController.view.removeFromSuperview()
      
      if animated == false {
        oldCenterViewController.endAppearanceTransition()
      }
    }
    
    self._centerViewController = centerViewController
    
    if self._centerViewController != nil {
      self.addChildViewController(self._centerViewController!)
      self._centerViewController!.view.frame = self.childControllerContainerView.bounds
      self.centerContainerView.addSubview(self._centerViewController!.view)
      self.childControllerContainerView.bringSubviewToFront(self.centerContainerView)
      self._centerViewController!.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//      self.updateShadowForCenterView()
      
      if animated == false {
        // If drawer is offscreen, then viewWillAppear: will take care of this
        if self.view.window != nil {
          self._centerViewController!.beginAppearanceTransition(true, animated: false)
          self._centerViewController!.endAppearanceTransition()
        }
        
        self._centerViewController!.didMoveToParentViewController(self)
      }
    }
  }
  
}
