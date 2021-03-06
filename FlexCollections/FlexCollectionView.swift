//
//  FlexCollectionView.swift
//  FlexCollections
//
//  Created by Martin Rehder on 21.09.16.
/*
 * Copyright 2016-present Martin Jacob Rehder.
 * http://www.rehsco.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


import UIKit
import StyledLabel
import FlexViews

public protocol FlexCollectionViewDelegate {
    func onFlexCollectionItemSelected(_ view: FlexCollectionView, item: FlexCollectionItem)
    func onFlexCollectionItemMoved(_ view: FlexCollectionView, item: FlexCollectionItem)
}

public enum FlexCollectionCellDisplayMode {
    case normal
    case iconified(size: CGSize)
}

@IBDesignable
open class FlexCollectionView: FlexView, UICollectionViewDataSource, UICollectionViewDelegate, FlexCollectionViewCellTouchedDelegate, UICollectionViewDelegateFlowLayout {
    let simpleHeaderViewID = "SimpleHeaderView"
    let emptyHeaderViewID = "EmptyHeaderView"
    
    private var justCreated = true
    
    fileprivate var _itemCollectionView: UICollectionView?
    open var collectionItemTypeMap: [String:String] = [:]
    
    open var contentDic : [String:[FlexCollectionItem]]?
    var sections : [FlexCollectionSection] = []
    
    open var flexCollectionDelegate: FlexCollectionViewDelegate?
    
    open var cellSwipeEnabled: Bool = true
    fileprivate var cellSwipeMenuActiveCell: IndexPath?
    
    open var isRefreshControlAvailable = true
    open var refreshControl: UIRefreshControl?
    
    open var itemCollectionView: UICollectionView {
        get {
            return _itemCollectionView!
        }
    }
    
    open var cellDisplayMode: FlexCollectionCellDisplayMode = .normal {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var forceHeaderTopWhenIconifiedDisplayMode: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open dynamic var centerCellsHorizontally: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open dynamic var viewMargins: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open dynamic var defaultCellSize: CGSize = CGSize(width: 120, height: 50) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var allowsMultipleSelection = false {
        didSet {
            self._itemCollectionView?.allowsMultipleSelection = self.allowsMultipleSelection
        }
    }
    
    @IBInspectable
    open var allowsSelection = true {
        didSet {
            self._itemCollectionView?.allowsSelection = self.allowsSelection
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.createView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createView()
    }
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizer.State.began:
            guard let selectedIndexPath = self.itemCollectionView.indexPathForItem(at: gesture.location(in: self.itemCollectionView)) else {
                break
            }
            self.itemCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizer.State.changed:
            self.itemCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizer.State.ended:
            self.itemCollectionView.endInteractiveMovement()
        default:
            self.itemCollectionView.cancelInteractiveMovement()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.setupView()
    }
    
    func createView() {
        self.backgroundColor = nil
        
        self._itemCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.itemCollectionView.dataSource = self
        self.itemCollectionView.delegate = self
        self.itemCollectionView.backgroundColor = .clear
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FlexCollectionView.handleLongGesture(_:)))
        self.itemCollectionView.addGestureRecognizer(longPressGesture)
        
        if self.contentDic == nil {
            self.contentDic = [:]
        }
        
        self.registerDefaultCells()
        
        self.itemCollectionView.register(SimpleHeaderCollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: simpleHeaderViewID)
        self.itemCollectionView.register(EmptyHeaderCollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: emptyHeaderViewID)
        
        self.itemCollectionView.allowsMultipleSelection = self.allowsMultipleSelection
        self.itemCollectionView.allowsSelection = self.allowsSelection
        
        self.addSubview(self.itemCollectionView)
    }
    
    func registerDefaultCells() {
        self.registerCell(FlexBaseCollectionItem.classForCoder(), cellClass: FlexBaseCollectionViewCell.classForCoder())
        self.registerCell(FlexColorCollectionItem.classForCoder(), cellClass: FlexColorCollectionViewCell.classForCoder())
        self.registerCell(FlexSwitchCollectionItem.classForCoder(), cellClass: FlexSwitchCollectionViewCell.classForCoder())
        self.registerCell(FlexSliderCollectionItem.classForCoder(), cellClass: FlexSliderCollectionViewCell.classForCoder())
        self.registerCell(FlexSnapStepperCollectionItem.classForCoder(), cellClass: FlexSnapStepperCollectionViewCell.classForCoder())
        self.registerCell(FlexTextViewCollectionItem.classForCoder(), cellClass: FlexTextViewCollectionViewCell.classForCoder())
        self.registerCell(FlexTextFieldCollectionItem.classForCoder(), cellClass: FlexTextFieldCollectionViewCell.classForCoder())
        self.registerCell(FlexImageCollectionItem.classForCoder(), cellClass: FlexImageCollectionViewCell.classForCoder())
        self.registerCell(FlexButtonCollectionItem.classForCoder(), cellClass: FlexButtonCollectionViewCell.classForCoder())
        self.registerCell(FlexMenuCollectionItem.classForCoder(), cellClass: FlexMenuCollectionViewCell.classForCoder())
        self.registerCell(FlexCardViewCollectionItem.classForCoder(), cellClass: FlexCardViewCollectionViewCell.classForCoder())
        self.registerCell(FlexCardTextViewCollectionItem.classForCoder(), cellClass: FlexCardTextViewCollectionViewCell.classForCoder())
    }
    
    open func registerCell(_ itemClass: AnyClass, cellClass: AnyClass) {
        self.collectionItemTypeMap[itemClass.description()] = cellClass.description()
        self.itemCollectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.description())
    }
    
    func setupView() {
        self.setupCollectionView()
        self.addRefreshControl()
    }
    
    func setupCollectionView() {
        if self.justCreated {
            self.justCreated = false
            self.itemCollectionView.frame = self.getViewRect().inset(by: self.viewMargins)
        }
        else {
            UIView.animate(withDuration: 0.25, animations: {
                self.itemCollectionView.frame = self.getViewRect().inset(by: self.viewMargins)
            })
        }
    }
    
    // MARK: - public
    
    open func removeAllSections() {
        self.sections.removeAll()
        self.contentDic?.removeAll()
        self.itemCollectionView.reloadData()
    }
    
    open func addSection(_ title: NSAttributedString? = nil, height: CGFloat? = nil, insets: UIEdgeInsets? = nil) -> String {
        let s = FlexCollectionSection(reference: UUID().uuidString, title: title)
        if let h = height {
            s.height = h
        }
        if let ins = insets {
            s.insets = ins
        }
        self.sections.append(s)
        self.contentDic?[s.reference] = []
        return s.reference
    }
    
    open func getSection(_ sectionReference: String) -> FlexCollectionSection? {
        for sec in self.sections {
            if sec.reference == sectionReference {
                return sec
            }
        }
        return nil
    }

    open func getSection(atIndex idx: Int) -> FlexCollectionSection? {
        if idx < self.sections.count {
            return self.sections[idx]
        }
        return nil
    }

    open func sectionReference(atIndex: Int) -> String? {
        if atIndex < self.sections.count {
            let sec = self.sections[atIndex]
            return sec.reference
        }
        return nil
    }
    
    open func addItem(_ sectionReference: String, item: FlexCollectionItem) {
        self.contentDic?[sectionReference]?.append(item)
        item.sectionReference = sectionReference
    }
    
    open func selectItem(_ itemReference: String) {
        if let itemPosition = self.getIndexPathForItem(itemReference) {
            itemCollectionView.selectItem(at: itemPosition, animated: true, scrollPosition: UICollectionView.ScrollPosition())
            itemCollectionView.isPagingEnabled = false
            itemCollectionView.scrollToItem(at: itemPosition, at: .centeredHorizontally, animated: true)
            itemCollectionView.isPagingEnabled = true
        }
    }

    open func deselectItem(_ itemReference: String) {
        if let ip = self.getIndexPathForItem(itemReference) {
            self.itemCollectionView.deselectItem(at: ip, animated: true)
        }
    }
    
    open func selectAllVisibleCells() {
        let vip = self.itemCollectionView.indexPathsForVisibleItems
        for ip in vip {
            self.itemCollectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }
    }
    
    open func deselectAllVisibleCells() {
        let vip = self.itemCollectionView.indexPathsForVisibleItems
        for ip in vip {
            self.itemCollectionView.deselectItem(at: ip, animated: false)
        }
    }
    
    open func updateCellForItem(_ itemReference: String) {
        if let indexPath = self.getIndexPathForItem(itemReference) {
            self.itemCollectionView.cellForItem(at: indexPath)?.setNeedsLayout()
        }
    }
    
    // MARK: - Collection View Callbacks
    
    open func getIndexPathForItem(_ itemReference: String) -> IndexPath? {
        var s: Int = 0
        for sec in self.sections {
            var row: Int = 0
            if let items = self.contentDic?[sec.reference] {
                for item in items {
                    if item.reference == itemReference {
                        return IndexPath(row: row, section: s)
                    }
                    row += 1
                }
            }
            s += 1
        }
        return nil
    }
    
    open func getItemForIndexPath(_ index: IndexPath) -> FlexCollectionItem? {
        let row: Int = index.row
        let section: Int = index.section
        if section < self.sections.count {
            let sec = self.sections[section]
            if let items = self.contentDic?[sec.reference], row < items.count {
                return items[row]
            }
        }
        return nil
    }
    
    open func getItemForReference(_ itemReference: String) -> FlexCollectionItem? {
        for sec in self.sections {
            if let items = self.contentDic?[sec.reference] {
                for item in items {
                    if item.reference == itemReference {
                        return item
                    }
                }
            }
        }
        return nil
    }
    
    open func removeItem(_ item: FlexCollectionItem) {
        if let items = self.contentDic?[item.sectionReference!] {
            if let idx = items.firstIndex(of: item) {
                self.contentDic?[item.sectionReference!]?.remove(at: idx)
            }
        }
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sec = self.sections[section]
        if let items = self.contentDic?[sec.reference] {
            return items.count
        }
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let item = self.getItemForIndexPath(indexPath) {
            if let cellClassStr = collectionItemTypeMap[item.classForCoder.description()] {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClassStr, for:indexPath) as? FlexCollectionViewCell {
                    cell._item = item
                    cell.cellStyler = item.cellStyler
                    cell.reference = item.reference
                    cell.flexCellTouchDelegate = self
                    cell.displayMode = self.cellDisplayMode
                    cell.forceHeaderTopWhenIconifiedDisplayMode = self.forceHeaderTopWhenIconifiedDisplayMode
                    if item.swipeLeftMenuItems != nil || item.swipeRightMenuItems != nil {
                        let lswipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftGestureAction(_:)))
                        lswipe.direction = .left
                        cell.addGestureRecognizer(lswipe)
                        let rswipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightGestureAction(_:)))
                        rswipe.direction = .right
                        cell.addGestureRecognizer(rswipe)
                    }
                    item.cellStyler?.prepareStyle(forCell: cell)
                    return cell
                }
            }
        }
        return UICollectionViewCell()
    }
    
    @objc func swipeLeftGestureAction(_ recognizer: UISwipeGestureRecognizer) {
        if self.cellSwipeEnabled, let cell = recognizer.view as? FlexCollectionViewCell {
            cell.swipeLeft()
            self.cellSwipeMenuActiveCell = self.itemCollectionView.indexPath(for: cell)
        }
    }
    
    @objc func swipeRightGestureAction(_ recognizer: UISwipeGestureRecognizer) {
        if self.cellSwipeEnabled, let cell = recognizer.view as? FlexCollectionViewCell {
            cell.swipeRight()
            self.cellSwipeMenuActiveCell = self.itemCollectionView.indexPath(for: cell)
        }
    }
    
    func resetSwipedCell() {
        if let sip = self.cellSwipeMenuActiveCell {
            if let cell = self.itemCollectionView.cellForItem(at: sip) as? FlexCollectionViewCell {
                cell.animateSwipeReset()
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.getCellSize(indexPath: indexPath)
    }
    
    open func getCellSize(indexPath: IndexPath?) -> CGSize {
        if let ip = indexPath {
            if let item = self.getItemForIndexPath(ip) {
                switch self.cellDisplayMode {
                case .normal:
                    if let preferredSize = item.preferredCellSize {
                        return preferredSize
                    }
                case .iconified(let size):
                    return size
                }
            }
        }
        else {
            switch self.cellDisplayMode {
            case .normal:
                return self.defaultCellSize
            case .iconified(let size):
                return size
            }
        }
        return self.defaultCellSize
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sec = self.sections[indexPath.section]
            if let title = sec.title {
                if let headerView = self.itemCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: simpleHeaderViewID, for: indexPath) as? SimpleHeaderCollectionReusableView {
                    headerView.title?.label.attributedText = title
                    return headerView
                }
            }
            if let headerView = self.itemCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: emptyHeaderViewID, for: indexPath) as? EmptyHeaderCollectionReusableView {
                return headerView
            }
        }
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = self.getItemForIndexPath(indexPath) {
            self.flexCollectionDelegate?.onFlexCollectionItemSelected(self, item: item)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let ssec = self.sections[sourceIndexPath.section]
        let tsec = self.sections[destinationIndexPath.section]
        
        if let item = self.getItemForIndexPath(sourceIndexPath) {
            self.contentDic?[ssec.reference]?.remove(at: sourceIndexPath.row)
            self.contentDic?[tsec.reference]?.insert(item, at: destinationIndexPath.row)
            item.sectionReference = tsec.reference
            self.flexCollectionDelegate?.onFlexCollectionItemMoved(self, item: item)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if let item = self.getItemForIndexPath(indexPath) {
            return item.canMoveItem
        }
        return false
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sec = self.sections[section]
        return CGSize(width: 0, height: sec.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if self.centerCellsHorizontally {
            if let secRef = self.sectionReference(atIndex: section), let itemCount = self.contentDic?[secRef]?.count, let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                let cellCount = CGFloat(itemCount)
                
                if cellCount > 0 {
                    let spacing:CGFloat = flowLayout.minimumInteritemSpacing * 0.5
                    let cellWidth = self.getCellSize(indexPath: nil).width + spacing
                    let totalCellWidth = cellWidth*cellCount + spacing * (cellCount-1)
                    let ci = self.viewMargins.left + self.viewMargins.right
                    let contentWidth = collectionView.frame.size.width - ci
                    
                    if (totalCellWidth < contentWidth) {
                        let padding = (contentWidth - totalCellWidth) / 2.0
                        let sec = self.sections[section]
                        return UIEdgeInsets.init(top: sec.insets.top, left: padding, bottom: sec.insets.bottom, right: padding)
                    }
                }
            }
        }
        let sec = self.sections[section]
        return sec.insets
    }
    
    // MARK: - FlexCollectionViewCellTouchedDelegate
    
    open func onFlexCollectionViewCellTouched(_ item: FlexCollectionItem?, xRelPos: CGFloat, yRelPos: CGFloat) {
        if let item = item {
            // Do not change selection when image view inside cell is touched and image view action handler is defined
            if let baseItem = item as? FlexBaseCollectionItem {
                if baseItem.imageViewActionHandler != nil {
                    if let ip = getIndexPathForItem(item.reference) {
                        if let cell = itemCollectionView.cellForItem(at: ip) as? FlexBaseCollectionViewCell, let imageView = cell.imageView {
                            let itemViewBounds = imageView.frame
                            let touchX = cell.frame.size.width * xRelPos
                            let touchY = cell.frame.size.height * yRelPos
                            if itemViewBounds.contains(CGPoint(x: touchX, y: touchY)) {
                                return
                            }
                        }
                    }
                }
            }
            
            if let ip = self.getIndexPathForItem(item.reference) {
                if let selIP = self.itemCollectionView.indexPathsForSelectedItems, selIP.contains(ip) {
                    self.itemCollectionView.deselectItem(at: ip, animated: true)
                    item.itemDeselectionActionHandler?()
                }
                else if item.isSelected {
                    self.itemCollectionView.deselectItem(at: ip, animated: true)
                    item.itemDeselectionActionHandler?()
                }
                else if !item.isSelected {
                    self.itemCollectionView.selectItem(at: ip, animated: true, scrollPosition: UICollectionView.ScrollPosition())
                    self.flexCollectionDelegate?.onFlexCollectionItemSelected(self, item: item)
                    item.itemSelectionActionHandler?()
                    item.itemPrecisionSelectionActionHandler?(xRelPos, yRelPos)
                    if let autoDeselectTime = item.autoDeselectCellAfter {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + autoDeselectTime, execute: {
                            self.itemCollectionView.deselectItem(at: ip, animated: true)
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Top Bar
    
    func addRefreshControl() {
        if self.refreshControl == nil && self.isRefreshControlAvailable {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.tintColor = .clear
            self.refreshControl?.addTarget(self, action: #selector(FlexCollectionView.refreshControlAction), for: UIControl.Event.valueChanged)
        }
        if let rc = self.refreshControl {
            if !rc.isDescendant(of: self.itemCollectionView) {
                self.itemCollectionView.addSubview(rc)
            }
        }
    }
    
    @objc func refreshControlAction(){
        self.showTopBar {
            self.itemCollectionView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.refreshControl?.endRefreshing()
            self.setNeedsLayout()
            self.itemCollectionView.reloadData()
        }
    }
    
    open override func hideTopBar(completionHandler: (() -> Void)? = nil) {
        super.hideTopBar {
            UIView.animate(withDuration: 0.25, animations: {
                self.itemCollectionView.frame = self.getViewRect().inset(by: self.viewMargins)
            })
        }
    }
}

