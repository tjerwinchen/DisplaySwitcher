//
//  BaseLayoutAttributes.swift
//  YALLayoutTransitioning
//
//  Created by Roman on 09.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

public class BaseLayoutAttributes: UICollectionViewLayoutAttributes {
    
   public var transitionProgress: CGFloat = 0.0
   public var nextLayoutCellFrame = CGRect.zero
   public var layoutState: CollectionViewLayoutState = .listLayoutState
    
    override public func copy(with zone: NSZone?) -> AnyObject {
        let copy = super.copy(with: zone) as! BaseLayoutAttributes
        copy.transitionProgress = transitionProgress
        copy.nextLayoutCellFrame = nextLayoutCellFrame
        copy.layoutState = layoutState
        
        return copy
    }
    
    override public func isEqual(_ object: AnyObject?) -> Bool {
        if let attributes = object as? BaseLayoutAttributes {
            if attributes.transitionProgress == transitionProgress && nextLayoutCellFrame == nextLayoutCellFrame  && layoutState == layoutState {
                return super.isEqual(object)
            }
        }
        
        return false
    }
    
}
