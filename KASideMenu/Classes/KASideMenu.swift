//
//  KASideMenu.swift
//  KASideMenu
//
//  Created by ZhihuaZhang on 09/12/2018.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit

open class KASideMenu: UIViewController {

    public struct Config {
        public var animationDuration = 0.2
        public var leftPadding: CGFloat = 60
        public var rightPadding: CGFloat = 60
        public var shadowWidth: CGFloat = 5
        public var shadowOpacity: Float = 0.5
        public var shadowRadius: CGFloat = 5
        public var thresholdWidth: CGFloat?
        public var thresholdPercentage: CGFloat?
        public var thresholdSpeed: CGFloat = 300
    }
    
    open var leftMenuViewController: UIViewController?
    open var centerViewController: UIViewController?
    open var rightMenuViewController: UIViewController?
    
    open func showRight() {
        state = .rightMenuVisible
    }
    
    open func showLeft() {
        state = .leftMenuVisible
    }
    
    open func closeMenu() {
        state = .centerVisible
    }
    
    open var config = Config()
    
    private var rightMenuPadding: NSLayoutConstraint?
    private var leftMenuPadding: NSLayoutConstraint?
    
    private enum SideMenuState {
        case centerVisible, leftMenuVisible, rightMenuVisible
    }
    
    private var state: SideMenuState = .centerVisible {
        didSet {
            var alpha: CGFloat = 0.0
            
            switch state {
            case .centerVisible:
                leftMenuPadding?.constant = view.bounds.width
                rightMenuPadding?.constant = view.bounds.width
                alpha = 0.0
            case .leftMenuVisible:
                leftMenuPadding?.constant = config.rightPadding
                alpha = 0.3
            case .rightMenuVisible:
                rightMenuPadding?.constant = config.leftPadding
                alpha = 0.3
            }
            
            UIView.animate(withDuration: config.animationDuration,
                           delay:0.0,
                           options:.curveEaseInOut,
                           animations: {() -> Void in
                            self.maskView.alpha = alpha
                            self.view.layoutIfNeeded()
            },
                           completion: nil
            )
        }
    }
    
    private let maskView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        addCenterViewController()
        addMaskView()
        addLeftMenu()
        addRightMenu()
        
        addGesture()
        
        if config.thresholdWidth == nil && config.thresholdPercentage == nil {
            config.thresholdPercentage = 1 / 2
        } else if let width = config.thresholdWidth, config.thresholdPercentage == nil {
            config.thresholdPercentage = width / view.bounds.width
        }
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        //pass the tap event to child
        tapGesture.cancelsTouchesInView = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(menuDragged))
        view.addGestureRecognizer(panGesture)
        panGesture.cancelsTouchesInView = false
    }
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        if isTappedOutsideTheMenu(sender) {
            closeMenu()
        }
    }
    
    private func isTappedOutsideTheMenu(_ sender: UITapGestureRecognizer) -> Bool {
        let location = sender.location(in: view)
        
        if state == .rightMenuVisible {
            return location.x < config.leftPadding
        }
        
        if state == .leftMenuVisible {
            return abs(view.bounds.width - location.x) < config.rightPadding
        }
        
        return false
    }
    
    private func addCenterViewController() {
        guard let centerViewController = centerViewController else {
            fatalError("need center viewcontroller")
        }
        
        addChildViewController(centerViewController)
        
        let centerView = centerViewController.view!
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerView)
        
        if #available(iOS 9.0, *) {
            centerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            centerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            centerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            centerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        }
        
        centerViewController.didMove(toParentViewController: self)
    }
    
    private func addMaskView() {
        view.addSubview(maskView)
        maskView.frame = view.bounds
    }
    
    private func addLeftMenu() {
        if let leftViewController = leftMenuViewController {
            addChildViewController(leftViewController)
            
            let leftView = leftViewController.view!
            leftView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(leftView)
            
            if #available(iOS 9.0, *) {
                leftView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
                leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
                leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
                leftMenuPadding = view.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: view.bounds.width)
                leftMenuPadding?.isActive = true
            }
            
            leftViewController.didMove(toParentViewController: self)
            
            setupMenu(menu: leftView, isLeft: true)
        }
    }
    
    private func addRightMenu() {
        if let rightViewController = rightMenuViewController {
            addChildViewController(rightViewController)
            
            let rightView = rightViewController.view!
            rightView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(rightView)
            
            if #available(iOS 9.0, *) {
                rightView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
                rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
                rightMenuPadding = rightView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width)
                rightMenuPadding?.isActive = true
                rightView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            }
            
            rightViewController.didMove(toParentViewController: self)
            
            setupMenu(menu: rightView, isLeft: false)
        }
    }
    
    private func setupMenu(menu: UIView, isLeft: Bool) {
        let layer = menu.layer
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: isLeft ? config.shadowWidth : -config.shadowWidth, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = config.shadowOpacity;
        layer.shadowRadius = config.shadowRadius;
    }
    
    @objc private func menuDragged(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        
        if state == .rightMenuVisible {
            let constant = rightMenuPadding!.constant + point.x
            rightMenuPadding?.constant = max(0, constant)
        } else if state == .leftMenuVisible {
            let constant = leftMenuPadding!.constant - point.x
            leftMenuPadding?.constant = max(0, constant)
        }
        
        sender.setTranslation(.zero, in: view)
        
        if sender.state == .ended {
            state = isNeedCloseAutomatically(sender) ? .centerVisible : state
        }
    }
    
    private func isNeedCloseAutomatically(_ gesture: UIPanGestureRecognizer) -> Bool {
        if isCloseGesture(gesture) && abs(gesture.velocity(in: view).x) > config.thresholdSpeed {
            return true
        }
        
        guard let percentage = config.thresholdPercentage else {
            return false
        }
        
        let padding = state == .leftMenuVisible ? leftMenuPadding : rightMenuPadding
        let visibleMenuWidth = abs(view.bounds.width - padding!.constant)
        
        return visibleMenuWidth < view.bounds.width * percentage
    }

    private func isCloseGesture(_ gesture: UIPanGestureRecognizer) -> Bool {
        return (gesture.velocity(in: view).x < 0 && state == .leftMenuVisible) ||
            (gesture.velocity(in: view).x > 0 && state == .rightMenuVisible)
    }
}
