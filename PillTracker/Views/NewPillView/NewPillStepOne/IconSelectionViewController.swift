//
//  IconSelectionViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

class IconSelectionViewController: UIViewController {
    // MARK: - Public Properties
    var images: [UIImage?] = []
    private let imagesFormTypes = [
        UIImage(named: "capsule"),
        UIImage(named: "tablet"),
        UIImage(named: "drops"),
        UIImage(named: "syrup"),
        UIImage(named: "injection"),
        UIImage(named: "ointment"),
        UIImage(named: "spray"),
        UIImage(named: "nasalspray"),
        UIImage(named: "vitamins")
    ]
    
    var selectedIcon: ((UIImage?) -> Void)?
    
    // MARK: - Private Properties
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 18
        layout.minimumLineSpacing = 18
        layout.sectionInset = UIEdgeInsets(top: 20, left: 25, bottom: 20, right: 25)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.register(IconCell.self, forCellWithReuseIdentifier: "IconCell")
        return collectionView
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension IconSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesFormTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
        
        let selectedImage = imagesFormTypes[indexPath.item]
        
        cell.imageView.image = selectedImage
        
        if selectedImage == nil {
            print("Image not found for index: \(indexPath.item)")
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension IconSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = imagesFormTypes[indexPath.item]
        
        selectedIcon?(selectedImage)
        dismiss(animated: true)
    }
}

extension IconSelectionViewController: UIViewControllerTransitioningDelegate {
    func presentAsBottomSheet(on parent: UIViewController) {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
        parent.present(self, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
