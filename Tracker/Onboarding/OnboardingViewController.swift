//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 07.07.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private let coreDataManager: CoreDataManager
    
    private var pages = [UIViewController]()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = UIColor.ypBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingPages()
        setupLayoutAndConstraints()
        dataSource = self
        delegate = self
    }
    
    private func setupLayoutAndConstraints() {
        view.addSubview(pageControl)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupOnboardingPages() {
        let firstPage = createOnboardingPage(with: .onboardingFirstPage, text: "Отслеживайте только то, что хотите")
        let secondPage = createOnboardingPage(with: .onboardingSecondPage, text: "Даже если это\nне литры воды и йога")
        
        pages.append(firstPage)
        pages.append(secondPage)
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
    }
    
    @objc
    private func buttonDidTapped() {
        OnboardingStorage.hasSeenOnboarding = true
        guard let window = view.window else { return }
        window.rootViewController = TabBarController(coreDataManager: coreDataManager)
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
    
    private func createOnboardingPage(with image: UIImage, text: String) -> UIViewController {
        let onboardingViewController = UIViewController()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        onboardingViewController.view.addSubview(imageView)
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 2
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        onboardingViewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: onboardingViewController.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: onboardingViewController.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: onboardingViewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: onboardingViewController.view.trailingAnchor),
            
            label.centerYAnchor.constraint(equalTo: onboardingViewController.view.centerYAnchor, constant: 68),
            label.leadingAnchor.constraint(equalTo: onboardingViewController.view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: onboardingViewController.view.trailingAnchor, constant: -16)
        ])
        return onboardingViewController
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}
