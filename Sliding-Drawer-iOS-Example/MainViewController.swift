//
//  MainViewController.swift
//  Sliding-Drawer-iOS-Example
//
//  Created by Christophe ISHIMWE NGABO on 11/11/2021.
//

import UIKit

class MainViewController: UIViewController {
    
    private var isExpanded: Bool = false
    private let paddingForRotation: CGFloat = 150
    private var menuRevealWidth: CGFloat = 350
    
    private var menuShadowView: UIView!
    
    private var menuViewController: MenuViewController?
    private var navigationViewController: UINavigationController?
    
    private var menuTrailingConstraint: NSLayoutConstraint?
    
    public var gestureEnabled: Bool = true
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    private var tapGestureRecognizer: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.menuViewController = storyboard?.instantiateViewController(identifier: "MENU-ID") as? MenuViewController
        self.navigationViewController = storyboard?.instantiateViewController(identifier: "MAIN-ID") as? UINavigationController
        if let menuController = menuViewController, let navigationController = navigationViewController {
            
            self.menuShadowView = UIView(frame: self.view.bounds)
            self.menuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.menuShadowView.backgroundColor = .black
            self.menuShadowView.alpha = 0.0
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
            self.tapGestureRecognizer?.numberOfTapsRequired = 1
            self.tapGestureRecognizer?.delegate = self
            view.insertSubview(self.menuShadowView, at: 1)
            
            menuController.menuDelegate = self
            view.insertSubview(menuController.view, at: 2)
            addChild(menuController)
            menuController.didMove(toParent: self)
            menuController.view.translatesAutoresizingMaskIntoConstraints = false
            self.menuTrailingConstraint = menuController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.menuRevealWidth - self.paddingForRotation)
            self.menuTrailingConstraint?.isActive = true
            
            NSLayoutConstraint.activate([
                menuController.view.widthAnchor.constraint(equalToConstant: self.menuRevealWidth),
                menuController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                menuController.view.topAnchor.constraint(equalTo: view.topAnchor)
            ])
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
                    panGestureRecognizer.delegate = self
                    view.addGestureRecognizer(panGestureRecognizer)

            if let homeViewController = navigationController.viewControllers.first as? HomeViewController {
                homeViewController.homeDelegate = self
            }
            view.insertSubview(navigationController.view, at: 0)
            addChild(navigationController)
            
            navigationController.didMove(toParent: self)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.menuTrailingConstraint?.constant = self.isExpanded ? 0 : (-self.menuRevealWidth - self.paddingForRotation)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIViewController {
    
    func revealViewController() -> HomeViewController? {
        var viewController: UIViewController? = self
        if viewController != nil && viewController is HomeViewController {
            return viewController! as? HomeViewController
        }
        while (!(viewController is HomeViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is HomeViewController {
            return viewController as? HomeViewController
        }
        return nil
    }
}

extension MainViewController: MenuDelegate, HomeDelegate {
    
    /*
     MenuViewController: Handle item clicked event
     */
    func menuItemDidClicked(index: Int, value: String) {
        if let gestureRecognizer = tapGestureRecognizer {
            view.removeGestureRecognizer(gestureRecognizer)
        }
        self.setMenuState(expanded: self.isExpanded ? false : true)
    }
    
    /*
     HomeViewController: Handle menu button clicked event
     */
    func menuDidClicked() {
        if let gestureRecognizer = tapGestureRecognizer {
            view.addGestureRecognizer(gestureRecognizer)
        }
        self.setMenuState(expanded: self.isExpanded ? false : true)
    }
    
    func setMenuState(expanded: Bool) {
        if expanded {
            self.animateMenu(targetPosition: 0) { _ in
                self.isExpanded = true
            }
            UIView.animate(withDuration: 0.5) { self.menuShadowView.alpha = 0.6 }
        } else {
            self.animateMenu(targetPosition: -self.menuRevealWidth - self.paddingForRotation) { _ in
                self.isExpanded = false
            }
            UIView.animate(withDuration: 0.5) { self.menuShadowView.alpha = 0.0 }
        }
    }

    func animateMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            self.menuTrailingConstraint?.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                self.setMenuState(expanded: false)
            }
        }
        if let gestureRecognizer = tapGestureRecognizer {
            view.removeGestureRecognizer(gestureRecognizer)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let menuController = self.menuViewController, (touch.view?.isDescendant(of: menuController.view))! {
            return false
        }
        return true
    }
    
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        guard gestureEnabled == true else { return }

        let position: CGFloat = sender.translation(in: self.view).x
        let velocity: CGFloat = sender.velocity(in: self.view).x

        switch sender.state {
        case .began:
            if velocity > 0, self.isExpanded {
                sender.state = .cancelled
            }
            if velocity > 0, !self.isExpanded {
                self.draggingIsEnabled = true
            }
            else if velocity < 0, self.isExpanded {
                self.draggingIsEnabled = true
            }

            if self.draggingIsEnabled {
                let velocityThreshold: CGFloat = 550
                if abs(velocity) > velocityThreshold {
                    self.setMenuState(expanded: self.isExpanded ? false : true)
                    self.draggingIsEnabled = false
                    return
                }
                self.panBaseLocation = 0.0
                if self.isExpanded {
                    self.panBaseLocation = self.menuRevealWidth
                }
            }
        case .changed:
            if self.draggingIsEnabled {
                let xLocation: CGFloat = self.panBaseLocation + position
                let percentage = (xLocation * 150 / self.menuRevealWidth) / self.menuRevealWidth

                let alpha = percentage >= 0.6 ? 0.6 : percentage
                self.menuShadowView.alpha = alpha

                // Move side menu while dragging
                if xLocation <= self.menuRevealWidth {
                    self.menuTrailingConstraint?.constant = xLocation - self.menuRevealWidth
                }
            }
        case .ended:
            self.draggingIsEnabled = false
            if let constraint = self.menuTrailingConstraint?.constant {
                let movedMoreThanHalf = constraint > -(self.menuRevealWidth * 0.5)
                self.setMenuState(expanded: movedMoreThanHalf)
            }
        default:
            break
        }
    }
}
