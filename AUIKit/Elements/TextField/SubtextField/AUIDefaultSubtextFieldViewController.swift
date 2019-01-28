//
//  AUIDefaultSubtextFieldViewController.swift
//  AUIKit
//
//  Created by Ihor Myroniuk on 1/25/19.
//

import Foundation

open class AUIDefaultSubtextFieldViewController: AUIDefaultSubcontrolViewController, AUISubtextFieldViewController, AUITextFieldControllerDidChangeTextDelegate, AUITextFieldControllerDidTapReturnKeyDelegate, AUITextFieldControllerDidBeginEditingDelegate, AUITextFieldControllerDidEndEditingDelegate, AUITextFieldControllerDidEndEditingReasonDelegate {
  
  // MARK: Delegates
  
  open weak var subtextFieldControllerDidChangeTextDelegate: AUITextFieldControllerDidChangeTextDelegate?
  open weak var subtextFieldControllerDidTapReturnKeyDelegate: AUITextFieldControllerDidTapReturnKeyDelegate?
  open weak var subtextFieldControllerDidBeginEditingDelegate: AUITextFieldControllerDidBeginEditingDelegate?
  open weak var subtextFieldControllerDidEndEditingDelegate: AUITextFieldControllerDidEndEditingDelegate?
  open weak var subtextFieldControllerDidEndEditingReasonDelegate: AUITextFieldControllerDidEndEditingReasonDelegate?
  
  // MARK: SubtextField
  
  open var subtextFieldController: AUITextFieldController? {
    set { subviewController = newValue }
    get { return subviewController as? AUITextFieldController }
  }
  
  open override func setupSubviewController() {
    super.setupSubviewController()
    subtextFieldController?.didChangeTextDelegate = self
    subtextFieldController?.didTapReturnKeyDelegate = self
    subtextFieldController?.didBeginEditingDelegate = self
    subtextFieldController?.didEndEditingDelegate = self
    subtextFieldController?.didEndEditingReasonDelegate = self
  }
  
  open override func unsetupSubviewController() {
    super.unsetupSubviewController()
    subtextFieldController?.didChangeTextDelegate = nil
    subtextFieldController?.didTapReturnKeyDelegate = nil
    subtextFieldController?.didBeginEditingDelegate = nil
    subtextFieldController?.didEndEditingDelegate = nil
    subtextFieldController?.didEndEditingReasonDelegate = nil
  }
  
  // MARK: Events
  
  open func textFieldControllerDidEndEditing(_ controller: AUITextFieldController) {
    subtextFieldControllerDidEndEditingDelegate?.textFieldControllerDidEndEditing(controller)
  }
  
  open func textFieldControllerDidEndEditingReason(_ controller: AUITextFieldController, reason: UITextField.DidEndEditingReason) {
    subtextFieldControllerDidEndEditingReasonDelegate?.textFieldControllerDidEndEditingReason(controller, reason: reason)
  }
  
  open func textFieldControllerDidChangeText(_ controller: AUITextFieldController) {
    subtextFieldControllerDidChangeTextDelegate?.textFieldControllerDidChangeText(controller)
  }
  
  open func textFieldControllerDidTapReturnKey(_ controller: AUITextFieldController) {
    subtextFieldControllerDidTapReturnKeyDelegate?.textFieldControllerDidTapReturnKey(controller)
  }
  
  open func textFieldControllerDidBeginEditing(_ controller: AUITextFieldController) {
    subtextFieldControllerDidBeginEditingDelegate?.textFieldControllerDidBeginEditing(controller)
  }
  
}