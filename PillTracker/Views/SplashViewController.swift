//
//  SplashViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.03.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        let image = UIImage(named: "logoPillTracker")
        logoImageView.image = image
        return logoImageView
    }()
    
    var window: UIWindow?
    private let userStore = UserStore()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        activityIndicator.startAnimating()
        loadInitialData()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .background
        
        [logoImageView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150)

        ])
    }
    
    private func loadInitialData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(2)
                
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.determineNextViewController()
                }
            }
        }
        
    }
    
    private func determineNextViewController() {
        if let user = userStore.fetchUser(), let name = user.name, !name.isEmpty {
            transitionToMyPillsViewController(userName: name)
        } else {
            transitionToWelcomeViewController()
        }
    }
    
    private func transitionToWelcomeViewController() {
            let welcomeVC = WelcomeViewController()
            welcomeVC.userStore = userStore
            
            UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController = welcomeVC
            }, completion: nil)
        }
    
    private func transitionToMyPillsViewController(userName: String) {
            let myPillsVC = MyPillsViewController(userName: userName)
            let navController = UINavigationController(rootViewController: myPillsVC)
            
            UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController = navController
            }, completion: nil)
        }
    
}
