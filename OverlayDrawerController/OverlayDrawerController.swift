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
    if let drawerController = self.evo_drawerController {
      if self == drawerController.leftDrawerViewController || self.navigationController == drawerController.leftDrawerViewController {
        var rect = drawerController.view.bounds
        rect.size.width = 250
        return rect
      }
      
//      if self == drawerController.rightDrawerViewController || self.navigationController == drawerController.rightDrawerViewController {
//        var rect = drawerController.view.bounds
//        rect.size.width = drawerController.maximumRightDrawerWidth
//        rect.origin.x = CGRectGetWidth(drawerController.view.bounds) - rect.size.width
//        return rect
//      }
    }
    
    return CGRectNull
  }
}

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

private let DrawerMinimumAnimationDuration: CGFloat = 0.15
private let DrawerDefaultAnimationVelocity: CGFloat = 840.0
private let DrawerDefaultDampingFactor: CGFloat = 1.0
public typealias DrawerControllerDrawerVisualStateBlock = (OverlayDrawerController, DrawerSide, CGFloat) -> Void


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
  
  private var animatingDrawer: Bool = false {
    didSet {
      self.view.userInteractionEnabled = !self.animatingDrawer
    }
  }
  
  public var animationVelocity = DrawerDefaultAnimationVelocity
  public var shouldStretchDrawer = true
  public var drawerDampingFactor = DrawerDefaultDampingFactor
  public var drawerVisualStateBlock: DrawerControllerDrawerVisualStateBlock?
  
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
  // MARK: - Drawer Attributes
  //
  private var isOpen: Bool?
//  private var drawerView: UIView
//  private var menuHeight: CGFloat
//  private var menuWidth: CGFloat
//  private var outFrame: CGRect
//  private var inFrame: CGRect
  
  
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
  // MARK: - View Lifecycle
  //
  override public func viewDidLoad() {
    super.viewDidLoad()
    setUpDrawer()
  }
  
  //
  // MARK: - Drawer Setup
  //
  public func setUpDrawer() {
    println("setting up drawer")
    
    self.isOpen = false;
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
  
  //
  // MARK: - Helpers
  //
  private func resetDrawerVisualStateForDrawerSide(drawerSide: DrawerSide) {
    if let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide) {
      sideDrawerViewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      sideDrawerViewController.view.layer.transform = CATransform3DIdentity
      sideDrawerViewController.view.alpha = 1.0
    }
  }
  
  private func updateDrawerVisualStateForDrawerSide(drawerSide: DrawerSide, percentVisible: CGFloat) {
    if let drawerVisualState = self.drawerVisualStateBlock {
      drawerVisualState(self, drawerSide, percentVisible)
    } else if self.shouldStretchDrawer {
      self.applyOvershootScaleTransformForDrawerSide(drawerSide, percentVisible: percentVisible)
    }
  }
  
  private func applyOvershootScaleTransformForDrawerSide(drawerSide: DrawerSide, percentVisible: CGFloat) {
    if percentVisible >= 1.0 {
      var transform = CATransform3DIdentity
      
      if let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide) {
        if drawerSide == .Left {
          transform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)
          transform = CATransform3DTranslate(transform, 250 * (percentVisible - 1.0) / 2, 0, 0)
        } else if drawerSide == .Right {
          transform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)
          transform = CATransform3DTranslate(transform, -250 * (percentVisible - 1.0) / 2, 0, 0)
        }
        
        sideDrawerViewController.view.layer.transform = transform
      }
    }
  }

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
    
    if let sideDrawerViewControllerToHide = self.sideDrawerViewControllerForSide(drawerToHide) {
      self.childControllerContainerView.sendSubviewToBack(sideDrawerViewControllerToHide.view)
      sideDrawerViewControllerToHide.view.hidden = true
    }
    
    if let sideDrawerViewControllerToPresent = self.sideDrawerViewControllerForSide(drawer) {
      sideDrawerViewControllerToPresent.view.hidden = false
      self.resetDrawerVisualStateForDrawerSide(drawer)
      sideDrawerViewControllerToPresent.view.frame = sideDrawerViewControllerToPresent.evo_visibleDrawerFrame
      self.updateDrawerVisualStateForDrawerSide(drawer, percentVisible: 0.0)
      sideDrawerViewControllerToPresent.beginAppearanceTransition(true, animated: animated)
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
        self.prepareToPresentDrawer(drawerSide, animated: animated)
      }
      
      if sideDrawerViewController != nil {
        var newFrame: CGRect
        let oldFrame = self.centerContainerView.frame
        
        if drawerSide == .Left {
          newFrame = self.centerContainerView.frame
          newFrame.origin.x = 250
        } else {
          newFrame = self.centerContainerView.frame
          newFrame.origin.x = 0 - 250
        }
        
        let distance = abs(CGRectGetMinX(oldFrame) - newFrame.origin.x)
        let duration: NSTimeInterval = animated ? NSTimeInterval(max(distance / abs(velocity), DrawerMinimumAnimationDuration)) : 0.0
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: velocity / distance, options: options, animations: { () -> Void in
          self.setNeedsStatusBarAppearanceUpdate()
          self.centerContainerView.frame = newFrame
          self.updateDrawerVisualStateForDrawerSide(drawerSide, percentVisible: 1.0)
          }, completion: { (finished) -> Void in
            if drawerSide != self.openSide {
              sideDrawerViewController!.endAppearanceTransition()
            }
            
            self.openSide = drawerSide
            
            self.resetDrawerVisualStateForDrawerSide(drawerSide)
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
      
      self.updateDrawerVisualStateForDrawerSide(visibleSide, percentVisible: percentVisible)
      sideDrawerViewController?.beginAppearanceTransition(false, animated: animated)
      
      UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: velocity / distance, options: options, animations: { () -> Void in
        self.setNeedsStatusBarAppearanceUpdate()
        self.centerContainerView.frame = newFrame
        self.updateDrawerVisualStateForDrawerSide(visibleSide, percentVisible: 0.0)
        }, completion: { (finished) -> Void in
          sideDrawerViewController?.endAppearanceTransition()
          self.openSide = .None
          self.resetDrawerVisualStateForDrawerSide(visibleSide)
          self.animatingDrawer = false
          completion?(finished)
      })
    }
  }
  
}
