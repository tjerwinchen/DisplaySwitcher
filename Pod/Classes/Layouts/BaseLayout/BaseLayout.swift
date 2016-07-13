//
//  BaseLayout.swift
//  YALLayoutTransitioning
//
//  Created by Roman on 29.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let listLayoutCountOfColumns = 1
private let gridLayoutCountOfColumns = 3

public enum CollectionViewLayoutState {
    case listLayoutState
    case gridLayoutState
}

public class BaseLayout: UICollectionViewLayout {
    
    private let numberOfColumns: Int
    private let cellPadding: CGFloat = 6.0
    private let staticCellHeight: CGFloat
    private let nextLayoutStaticCellHeight: CGFloat
    private var previousContentOffset: NSValue?
    private var layoutState: CollectionViewLayoutState
  
    private var baseLayoutAttributes: [BaseLayoutAttributes]!
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - insets.left - insets.right
    }
    
    // MARK: - Lifecycle
  
    public init(staticCellHeight: CGFloat, nextLayoutStaticCellHeight: CGFloat, layoutState: CollectionViewLayoutState) {
        self.staticCellHeight = staticCellHeight
        self.numberOfColumns = (layoutState == .listLayoutState) ? listLayoutCountOfColumns : gridLayoutCountOfColumns
        self.layoutState = layoutState
        self.nextLayoutStaticCellHeight = nextLayoutStaticCellHeight
        
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewLayout
  
    override public func prepare() {
        super.prepare()
        
        baseLayoutAttributes = [BaseLayoutAttributes]()
        
        // cells layout
        contentHeight = 0
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffsets = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffsets.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: contentHeight, count: numberOfColumns)
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let height = cellPadding + staticCellHeight
            let frame = CGRect(x: xOffsets[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = BaseLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            baseLayoutAttributes.append(attributes)
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            column = column == (numberOfColumns - 1) ? 0 : column + 1
        }
    }
    
    override public func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in baseLayoutAttributes {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return baseLayoutAttributes[(indexPath as NSIndexPath).row]
    }
    
    override public class func layoutAttributesClass() -> AnyClass {
        return BaseLayoutAttributes.self
    }
    
    // Fix bug with content offset
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let previousContentOffsetPoint = previousContentOffset?.cgPointValue()
        let superContentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        if let previousContentOffsetPoint = previousContentOffsetPoint {
            if previousContentOffsetPoint.y == 0 {
                return previousContentOffsetPoint
            }
            if layoutState == CollectionViewLayoutState.listLayoutState {
                let offsetY = ceil(previousContentOffsetPoint.y + (staticCellHeight * previousContentOffsetPoint.y / nextLayoutStaticCellHeight) + cellPadding)
                return CGPoint(x: superContentOffset.x, y: offsetY)
            } else {
                let realOffsetY = ceil((previousContentOffsetPoint.y / nextLayoutStaticCellHeight * staticCellHeight / CGFloat(numberOfColumns)) - cellPadding)
                let offsetY = floor(realOffsetY / staticCellHeight) * staticCellHeight + cellPadding
                return CGPoint(x: superContentOffset.x, y: offsetY)
            }
        }
        
        return superContentOffset
    }
    
    override public func prepareForTransition(from oldLayout: UICollectionViewLayout) {
        previousContentOffset = NSValue(cgPoint:collectionView!.contentOffset)
        
        return super.prepareForTransition(from: oldLayout)
    }
    
    override public func finalizeLayoutTransition() {
        previousContentOffset = nil
        
        super.finalizeLayoutTransition()
    }
        
}
