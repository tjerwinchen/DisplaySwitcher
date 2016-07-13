//
//  TransitionManager.swift
//  YALLayoutTransitioning
//
//  Created by Roman on 23.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let finishTransitionValue = 1.0

public class TransitionManager {
    
    private var duration: TimeInterval
    private var collectionView: UICollectionView
    private var destinationLayout: UICollectionViewLayout
    private var layoutState: CollectionViewLayoutState
    private var transitionLayout: TransitionLayout!
    private var updater: CADisplayLink!
    private var start: TimeInterval!
    
    // MARK: - Lifecycle
    public init(duration: TimeInterval, collectionView: UICollectionView, destinationLayout: UICollectionViewLayout, layoutState: CollectionViewLayoutState) {
        self.collectionView = collectionView
        self.destinationLayout = destinationLayout
        self.layoutState = layoutState
        self.duration = duration
    }
    
    // MARK: - Public methods
    public func startInteractiveTransition() {
        UIApplication.shared().beginIgnoringInteractionEvents()
        transitionLayout = collectionView.startInteractiveTransition(to: destinationLayout, completion: { success, finish in
            if success && finish {
                self.collectionView.reloadData()
                UIApplication.shared().endIgnoringInteractionEvents()
            }
        }) as! TransitionLayout
        transitionLayout.layoutState = layoutState
        createUpdaterAndStart()
    }
    
    // MARK: - Private methods
    private func createUpdaterAndStart() {
        start = CACurrentMediaTime()
        updater = CADisplayLink(target: self, selector: #selector(updateTransitionProgress))
        updater.frameInterval = 1
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    dynamic func updateTransitionProgress() {
        var progress = (updater.timestamp - start) / duration
        progress = min(1, progress)
        progress = max(0, progress)
        transitionLayout.transitionProgress = CGFloat(progress)
      
        transitionLayout.invalidateLayout()
        if progress == finishTransitionValue {
            collectionView.finishInteractiveTransition()
            updater.invalidate()
        }
    }
}
