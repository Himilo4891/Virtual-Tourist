import Foundation
import UIKit


final class Constants: UICollectionViewFlowLayout {
    
    var numberOfItemsPerRow: Int = 3 {
        didSet {
            invalidateLayout()
        }
    }
    
    
    override func prepare() {
        super.prepare()
        
        if let collectionView = self.collectionView {
            var newItemSize = itemSize

            
            let itemsPerRow = CGFloat(max(numberOfItemsPerRow, 1))
            
            let totalSpacing = minimumInteritemSpacing * (itemsPerRow - 1.0)
            
            newItemSize.width = (collectionView.bounds.size.width - sectionInset.left - sectionInset.right - totalSpacing) / itemsPerRow
            
            
            if itemSize.height > 0 {
                let itemAspectRatio = itemSize.width / itemSize.height
                newItemSize.height = newItemSize.width / itemAspectRatio
            }
            
            itemSize = newItemSize
        }
    }
}
