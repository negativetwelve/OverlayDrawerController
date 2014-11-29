//
//  OverlayDrawerController.swift
//  ExampleOverlayDrawerController
//
//  Created by Mark Miyashita on 11/28/14.
//  Copyright (c) 2014 Mark Miyashita. All rights reserved.
//

import UIKit

extension UIViewController {
  var evo_drawerController: OverlayDrawerController? {
    var parentViewController = self.parentViewController
    
    while parentViewController != nil {
      if parentViewController!.isKindOfClass(OverlayDrawerController) {
        return parentViewController as? OverlayDrawerController
      }
      
      parentViewController = parentViewController!.parentViewController
    }
    
    return nil
  }
  
  var evo_visibleDrawerFrame: CGRect {
    let bounds = self.view.bounds
    return CGRectMake(0, 0, 250, bounds.height)
  }
  
  var evo_offscreenLeftDrawerFrame: CGRect {
    let bounds = self.view.bounds
    return CGRectMake(-250, 0, 250, bounds.height)
  }
  
  var evo_offscreenRightDrawerFrame: CGRect {
    if let drawerController = self.evo_drawerController {
      let bounds = drawerController.view.bounds
      return CGRectMake(bounds.width + 250, 0, 250, bounds.height)
    }
    return CGRectNull
  }
}

public enum DrawerSide: Int {
  case None
  case Left
  case Right
}

private let DrawerMinimumAnimationDuration: CGFloat = 0.15
private let DrawerDefaultAnimationVelocity: CGFloat = 840.0
private let DrawerDefaultDampingFactor: CGFloat = 1.0


private class DrawerCenterContainerView: UIView {
  private var openSide: DrawerSide = .None

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
  
  private var animatingDrawer: Bool = false {
    didSet {
      self.view.userInteractionEnabled = !self.animatingDrawer
    }
  }
  
  public var animationVelocity = DrawerDefaultAnimationVelocity
  public var shouldStretchDrawer = true
  public var drawerDampingFactor = DrawerDefaultDampingFactor
  
  private lazy var childControllerContainerView: UIView = {
    let childContainerViewFrame = self.view.bounds
    let childControllerContainerView = UIView(frame: childContainerViewFrame)
    childControllerContainerView.backgroundColor = .clearColor()
    childControllerContainerView.addSubview(self.shadowView)
    
    self.view.addSubview(childControllerContainerView)
    
    return childControllerContainerView
    }()
  
  private lazy var centerContainerView: DrawerCenterContainerView = {
    let centerFrame = self.view.bounds
    
    let centerContainerView = DrawerCenterContainerView(frame: centerFrame)
    centerContainerView.backgroundColor = .clearColor()
    centerContainerView.openSide = self.openSide
    self.view.addSubview(centerContainerView)
    
    return centerContainerView
  }()
  
  private lazy var shadowView: UIView = {
    let shadowView = UIView(frame: self.view.bounds)
    shadowView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: "tapOnShadow:")
    shadowView.addGestureRecognizer(tapGesture)

    return shadowView;
  }()
  
  public private(set) var openSide: DrawerSide = .None

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
    assert({ () -> Bool in
      return drawerSide != .None
      }(), "drawerSide cannot be .None")
    
    let currentSideViewController = self.sideDrawerViewControllerForSide(drawerSide)
    
    if currentSideViewController == viewController {
      return
    }
    
    if currentSideViewController != nil {
      currentSideViewController!.beginAppearanceTransition(false, animated: false)
      currentSideViewController!.view.removeFromSuperview()
      currentSideViewController!.endAppearanceTransition()
      currentSideViewController!.willMoveToParentViewController(nil)
      currentSideViewController!.removeFromParentViewController()
    }
    
    if drawerSide == .Left {
      self._leftDrawerViewController = viewController
    } else if drawerSide == .Right {
//      self._rightDrawerViewController = viewController
    }
    
    if viewController != nil {
      self.addChildViewController(viewController!)
      
      if (self.openSide == drawerSide) && (self.childControllerContainerView.subviews as NSArray).containsObject(self.centerContainerView) {
        self.childControllerContainerView.addSubview(viewController!.view)
//        self.childControllerContainerView.insertSubview(viewController!.view, belowSubview: self.centerContainerView)
        viewController!.beginAppearanceTransition(true, animated: false)
        viewController!.endAppearanceTransition()
      } else {
        self.childControllerContainerView.addSubview(viewController!.view)
//        self.childControllerContainerView.sendSubviewToBack(viewController!.view)
//        viewController!.view.hidden = true
      }
      
      viewController!.didMoveToParentViewController(self)
//      viewController!.view.frame = viewController!.evo_offscreenLeftDrawerFrame
      println(self.childControllerContainerView.frame)
      self.childControllerContainerView.frame = self.evo_offscreenLeftDrawerFrame
      println(self.childControllerContainerView.frame)
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
      self._centerViewController!.view.frame = self.view.bounds
      self.centerContainerView.addSubview(self._centerViewController!.view)
//      self.childControllerContainerView.bringSubviewToFront(self.centerContainerView)
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
  
  //
  // MARK: - Helpers
  //
  private func childViewControllerForSide(drawerSide: DrawerSide) -> UIViewController? {
    var childViewController: UIViewController?
    
    switch drawerSide {
    case .Left:
      childViewController = self.leftDrawerViewController
    case .Right:
      //childViewController = self.rightDrawerViewController
      childViewController = nil
    case .None:
      childViewController = self.centerViewController
    }
    
    return childViewController
  }

  private func sideDrawerViewControllerForSide(drawerSide: DrawerSide) -> UIViewController? {
    var sideDrawerViewController: UIViewController?
    
    if drawerSide != .None {
      sideDrawerViewController = self.childViewControllerForSide(drawerSide)
    }
    
    return sideDrawerViewController
  }
  
  private func prepareToPresentDrawer(drawer: DrawerSide, animated: Bool) {
    var drawerToHide: DrawerSide = .None
    
    if drawer == .Left {
      drawerToHide = .Right
    } else if drawer == .Right {
      drawerToHide = .Left
    }
    
//    if let sideDrawerViewControllerToHide = self.sideDrawerViewControllerForSide(drawerToHide) {
//      self.childControllerContainerView.sendSubviewToBack(sideDrawerViewControllerToHide.view)
//      sideDrawerViewControllerToHide.view.hidden = true
//    }
    
    if let sideDrawerViewControllerToPresent = self.sideDrawerViewControllerForSide(drawer) {

    }
  }

  //
  // MARK: - Toggle Drawer
  //
  public func toggleLeftDrawerSideAnimated(animated: Bool, completion: ((Bool) -> Void)?) {
    self.toggleDrawerSide(.Left, animated: animated, completion: completion)
  }
  
  public func toggleRightDrawerSideAnimated(animated: Bool, completion: ((Bool) -> Void)?) {
    self.toggleDrawerSide(.Right, animated: animated, completion: completion)
  }
  
  public func toggleDrawerSide(drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
    assert({ () -> Bool in
      return drawerSide != .None
      }(), "drawerSide cannot be .None")
    
    if self.openSide == DrawerSide.None {
      self.openDrawerSide(drawerSide, animated: animated, completion: completion)
    } else {
      if (drawerSide == DrawerSide.Left && self.openSide == DrawerSide.Left) || (drawerSide == DrawerSide.Right && self.openSide == DrawerSide.Right) {
        self.closeDrawerAnimated(animated, completion: completion)
      } else if completion != nil {
        completion!(false)
      }
    }
  }

  //
  // MARK: - Open Drawer
  //
  public func openDrawerSide(drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
    assert({ () -> Bool in
      return drawerSide != .None
      }(), "drawerSide cannot be .None")
    
    self.openDrawerSide(drawerSide, animated: animated, velocity: self.animationVelocity, animationOptions: nil, completion: completion)
  }

  private func openDrawerSide(drawerSide: DrawerSide, animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions, completion: ((Bool) -> Void)?) {
    assert({ () -> Bool in
      return drawerSide != .None
      }(), "drawerSide cannot be .None")
    
    if self.animatingDrawer {
      completion?(false)
    } else {
      self.animatingDrawer = animated
      let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide)
      
      if self.openSide != drawerSide {
//        self.prepareToPresentDrawer(drawerSide, animated: animated)
      }
      
      if sideDrawerViewController != nil {
        var newFrame: CGRect
        let oldFrame = self.centerContainerView.frame
        
        if drawerSide == .Left {
          newFrame = self.centerContainerView.frame
          //newFrame.origin.x = 250
        } else {
          newFrame = self.centerContainerView.frame
          newFrame.origin.x = 0 - 250
        }
        
        let distance = abs(CGRectGetMinX(oldFrame) - newFrame.origin.x)
        let duration: NSTimeInterval = animated ? NSTimeInterval(max(distance / abs(velocity), DrawerMinimumAnimationDuration)) : 0.0
        
        sideDrawerViewController!.beginAppearanceTransition(false, animated: true)
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: velocity / distance, options: options, animations: { () -> Void in
          self.setNeedsStatusBarAppearanceUpdate()
          
          println(self.childControllerContainerView.frame)
          self.childControllerContainerView.frame = self.evo_visibleDrawerFrame
          println(self.childControllerContainerView.frame)
          
          }, completion: { (finished) -> Void in
            if drawerSide != self.openSide {
              sideDrawerViewController!.endAppearanceTransition()
            }
            
            self.openSide = drawerSide
            
            self.animatingDrawer = false
            
            completion?(finished)
        })
      }
    }
  }
  
  //
  // MARK: - Close Drawer
  //
  public func closeDrawerAnimated(animated: Bool, completion: ((Bool) -> Void)?) {
    self.closeDrawerAnimated(animated, velocity: self.animationVelocity, animationOptions: nil, completion: completion)
  }
  
  private func closeDrawerAnimated(animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions, completion: ((Bool) -> Void)?) {
    if self.animatingDrawer {
      completion?(false)
    } else {
      self.animatingDrawer = animated
      let newFrame = self.childControllerContainerView.bounds
      
      let distance = abs(CGRectGetMinX(self.centerContainerView.frame))
      let duration: NSTimeInterval = animated ? NSTimeInterval(max(distance / abs(velocity), DrawerMinimumAnimationDuration)) : 0.0
      
      let leftDrawerVisible = CGRectGetMinX(self.centerContainerView.frame) > 0
      let rightDrawerVisible = CGRectGetMinX(self.centerContainerView.frame) < 0
      
      var visibleSide: DrawerSide = .None
      var percentVisible: CGFloat = 0.0
      
      if leftDrawerVisible {
        let visibleDrawerPoint = CGRectGetMinX(self.centerContainerView.frame)
        percentVisible = max(0.0, visibleDrawerPoint / 250)
        visibleSide = .Left
      } else if rightDrawerVisible {
        let visibleDrawerPoints = CGRectGetWidth(self.centerContainerView.frame) - CGRectGetMaxX(self.centerContainerView.frame)
        percentVisible = max(0.0, visibleDrawerPoints / 250)
        visibleSide = .Right
      }
      
      let sideDrawerViewController = self.sideDrawerViewControllerForSide(visibleSide)
      
      sideDrawerViewController?.beginAppearanceTransition(false, animated: animated)
      
      UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: velocity / distance, options: options, animations: { () -> Void in
        self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { (finished) -> Void in
          sideDrawerViewController?.endAppearanceTransition()
          self.openSide = .None
          self.animatingDrawer = false
          completion?(finished)
      })
    }
  }
  
  //
  // MARK: - UIActions
  //
  public func tapOnShadow(sender: UITapGestureRecognizer!) {
    println("tap on shadow")
    closeDrawerAnimated(true, completion: nil)
  }
  
}
