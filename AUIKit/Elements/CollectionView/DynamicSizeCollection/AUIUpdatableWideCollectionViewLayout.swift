//
//  AUIUpdatableWideCollectionViewLayout.swift
//  Copyright © 2019 BRANDER. All rights reserved.
//

import UIKit

public protocol AUIUpdatableCollectionViewLayoutDelegate: class {
  func getCellControllers() -> [AUICollectionViewCellController]
  func getIndexPath(for cellController: AUICollectionViewCellController) -> IndexPath?
  func getCellController(for indexPath: IndexPath) -> AUICollectionViewCellController?
}

public protocol AUIUpdatableCollectionViewLayout: class {
  var delegate: AUIUpdatableCollectionViewLayoutDelegate? { get set }
  var itemsLayoutAttributes: [UICollectionViewLayoutAttributes] { get set }
  func prepareForInsert(at indexPaths: [IndexPath])
  func prepareForDelete(at indexPaths: [IndexPath])
  func prepareForUpdate(at indexPaths: [IndexPath])
  func recalculateCellsSizes()
}

open class AUIUpdatableWideCollectionViewLayout: UICollectionViewLayout, AUIUpdatableCollectionViewLayout {
  
  // MARK: - Delegate
  
  weak public var delegate: AUIUpdatableCollectionViewLayoutDelegate?
  
  // MARK: - Private variables
  
  var contentViewHeight: CGFloat = 0
  private var oldSize: CGSize?
  
  public var itemsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
  
  let mockCollectionView: UICollectionView
  
  override public init() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 100, height: 100)
    mockCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    super.init()
    mockCollectionView.dataSource = self
    mockCollectionView.delegate = self
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Prepare
  
  override open func prepare() {
    super.prepare()
    
    guard let collectionView = collectionView  else { return }
    
    if let oldSize = oldSize, collectionView.bounds.size.width != oldSize.width {
      recalculateCellsSizes()
    }
    oldSize = collectionView.bounds.size
  }
  
  func getCellSize(for cellController: AUICollectionViewCellController) -> CGSize {
    let cellSize = calculateCellSize(for: cellController)
    return CGSize(width: collectionViewContentSize.width, height: cellSize.height)
  }
  
  func calculateCellSize(for cellController: AUICollectionViewCellController) -> CGSize {
    let indexPath = IndexPath(row: 0, section: 0)
    let oldView = (cellController as? AUIElementCollectionViewCellController)?.view
    let cell = cellController.cellForRowAtIndexPath(indexPath, collectionView: mockCollectionView)
    (cellController as? AUIElementCollectionViewCellController)?.view = oldView
    (cellController as? AUIElementCollectionViewCellController)?.controller.view = oldView
    let cellSize = cell.sizeThatFits(CGSize(width: collectionViewContentSize.width, height: CGFloat.greatestFiniteMagnitude))
    return cellSize
  }
  
  override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    if let oldSize = oldSize, oldSize != newBounds.size {
      return true
    }
    return false
  }
  
  override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return itemsLayoutAttributes.filter({ return rect.intersects($0.frame) })
  }
  
  override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return itemsLayoutAttributes.first { $0.indexPath == indexPath }
  }
  
  override open var collectionViewContentSize: CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: contentViewHeight)
  }
  
  open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
    mockCollectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
  }
  
  // MARK: - Prepare for insert
  
  open func prepareForInsert(at indexPaths: [IndexPath]) {
    let sortedIndexPaths = indexPaths.sorted()
    sortedIndexPaths.forEach { insertLayoutAttributes(for: $0) }
  }
  
  func insertLayoutAttributes(for indexPath: IndexPath) {
    guard let cellController = delegate?.getCellController(for: indexPath) else { return }
    let cellSize = getCellSize(for: cellController)
    let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    layoutAttributes.frame = calculateFrameForItem(indexPath: indexPath, itemSize: cellSize)
//    print("\(layoutAttributes.frame) for index: \(indexPath.row)")
    let attributesToChange = itemsLayoutAttributes.filter { $0.indexPath >= indexPath }
    attributesToChange.forEach {
      $0.indexPath.row += 1
      $0.frame.origin.y += cellSize.height
    }
    
    itemsLayoutAttributes.append(layoutAttributes)
    updateContentSize()
  }
  
  func updateContentSize() {
    contentViewHeight = itemsLayoutAttributes.max { $0.frame.maxY < $1.frame.maxY }?.frame.maxY ?? 0
  }
  
//  private func getHeightBefore(indexPath: IndexPath) -> CGFloat {
//    let attributesAbove = itemsLayoutAttributes.filter { $0.indexPath < indexPath }
//    let heightAbove = attributesAbove.reduce(into: 0, { (result, attribute) in
//      result += attribute.frame.height
//    })
//    return heightAbove
//  }
  
  // MARK: - Prepare for delete
  
  open func prepareForDelete(at indexPaths: [IndexPath]) {
    let sortedIndexPaths = indexPaths.sorted(by: > )
    sortedIndexPaths.forEach { deleteLayoutAttribute(for: $0) }
  }
  
  func deleteLayoutAttribute(for indexPath: IndexPath) {
    let foundLayoutAttribute = itemsLayoutAttributes.first { $0.indexPath == indexPath }
    guard let layoutAttribute = foundLayoutAttribute else { return }
    let attributesToChange = itemsLayoutAttributes.filter { $0.indexPath > indexPath }
    
    if let index = itemsLayoutAttributes.firstIndex(of: layoutAttribute) {
      itemsLayoutAttributes.remove(at: index)
    }
    attributesToChange.forEach {
      $0.frame.origin.y -= layoutAttribute.frame.height
      $0.indexPath.row -= 1
    }
    updateContentSize()
  }
  
  // MARK: - Prepare for update
  
  open func prepareForUpdate(at indexPaths: [IndexPath]) {
    indexPaths.forEach { updateLayoutAttribute(for: $0) }
  }

  private func updateLayoutAttribute(for indexPath: IndexPath) {
    deleteLayoutAttribute(for: indexPath)
    insertLayoutAttributes(for: indexPath)
  }
  
  // MARK: - Find layout attributes
  
  func findLayoutAttributes(for indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return itemsLayoutAttributes.first { $0.indexPath == indexPath }
  }
  
  func getSortedByIndexPathLayoutAttributes() -> [UICollectionViewLayoutAttributes] {
    return itemsLayoutAttributes.sorted { $0.indexPath < $1.indexPath }
  }
  
  open func recalculateCellsSizes() {
    guard let delegate = delegate else { return }
    let sortedLayoutAttributes = getSortedByIndexPathLayoutAttributes()
    sortedLayoutAttributes.forEach {
      if let cellController = delegate.getCellController(for: $0.indexPath) {
        let cellSize = getCellSize(for: cellController)
        $0.frame = calculateFrameForItem(indexPath: $0.indexPath, itemSize: cellSize)
      }
    }
    updateContentSize()
  }
  
  func getIndexPathBefore(indexPath: IndexPath) -> IndexPath? {
    guard indexPath.row > 0 else  { return nil }
    if indexPath.row > 0 {
      return IndexPath(row: indexPath.row - 1, section: indexPath.section)
    } else {
      let previousSection = indexPath.section - 1
      let itemsCount = collectionView?.numberOfItems(inSection: previousSection) ?? 0
      return IndexPath(row: itemsCount - 1, section: previousSection)
    }
  }
  
  func calculateFrameForItem(indexPath: IndexPath, itemSize: CGSize) -> CGRect {
    guard
      let indexPathBefore = getIndexPathBefore(indexPath: indexPath),
      let attributesBefore = findLayoutAttributes(for: indexPathBefore)else {
        return CGRect(origin: .zero, size: itemSize)
    }
    return CGRect(
      x: attributesBefore.frame.origin.x,
      y: attributesBefore.frame.maxY,
      width: itemSize.width,
      height: itemSize.height)
  }
  
}

extension AUIUpdatableWideCollectionViewLayout: UICollectionViewDataSource {
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
}

extension AUIUpdatableWideCollectionViewLayout: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 100)
  }
  
}
