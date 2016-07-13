//
//  UserViewController.swift
//  YALLayoutTransitioning
//
//  Created by Roman on 23.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import DisplaySwitcher

private let animationDuration: TimeInterval = 0.3

private let listLayoutStaticCellHeight: CGFloat = 80
private let gridLayoutStaticCellHeight: CGFloat = 165

class UserViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var rotationButton: RotationButton!
    
    private var users = UserDataProvider().generateFakeUsers()
    private var searchUsers = [User]()
    private var isTransitionAvailable = true
    private lazy var listLayout = BaseLayout(staticCellHeight: listLayoutStaticCellHeight, nextLayoutStaticCellHeight: gridLayoutStaticCellHeight, layoutState: .listLayoutState)
    private lazy var gridLayout = BaseLayout(staticCellHeight: gridLayoutStaticCellHeight, nextLayoutStaticCellHeight: listLayoutStaticCellHeight, layoutState: .gridLayoutState)
    private var layoutState: CollectionViewLayoutState = .listLayoutState
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        searchUsers = users
        rotationButton.isSelected = true
        setupCollectionView()
        addGestureRecognizerToNavBar()
    }
    
    // MARK: - Private methods
    private func setupCollectionView() {
        collectionView.collectionViewLayout = listLayout
        collectionView.register(UserCollectionViewCell.cellNib, forCellWithReuseIdentifier:UserCollectionViewCell.id)
    }
    
    private func addGestureRecognizerToNavBar() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserViewController.tapRecognized))
        navigationController!.navigationBar.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Actions
    @IBAction func buttonTapped(_ sender: AnyObject) {
        if !isTransitionAvailable {
            return
        }
        let transitionManager: TransitionManager
        if layoutState == .listLayoutState {
            layoutState = .gridLayoutState
            transitionManager = TransitionManager(duration: animationDuration, collectionView: collectionView!, destinationLayout: gridLayout, layoutState: layoutState)
        } else {
            layoutState = .listLayoutState
            transitionManager = TransitionManager(duration: animationDuration, collectionView: collectionView!, destinationLayout: listLayout, layoutState: layoutState)
        }
        transitionManager.startInteractiveTransition()
        rotationButton.isSelected = layoutState == .listLayoutState
        rotationButton.animationDuration = animationDuration
    }
    
    @IBAction func tapRecognized() {
        view.endEditing(true)
    }

}

extension UserViewController {
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.id, for: indexPath) as! UserCollectionViewCell
        if layoutState == .gridLayoutState {
            cell.setupGridLayoutConstraints(1, cellWidth: cell.frame.width)
        } else {
            cell.setupListLayoutConstraints(1, cellWidth: cell.frame.width)
        }
        cell.bind(searchUsers[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        let customTransitionLayout = TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
        return customTransitionLayout
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isTransitionAvailable = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isTransitionAvailable = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension UserViewController {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = users
        } else {
            searchUsers = searchUsers.filter { return $0.name.contains(searchText) }
        }
      
        collectionView.reloadData()
    }
    
}
    
