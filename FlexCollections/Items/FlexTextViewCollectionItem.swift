//
//  FlexTextViewCollectionItem.swift
//  FlexCollections
//
//  Created by Martin Rehder on 23.09.16.
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

open class FlexTextViewCollectionItem: FlexBaseCollectionItem {
    open var textTitle: NSAttributedString?
    open var textViewInsets: UIEdgeInsets = .zero
    open var textIsMutable: Bool = false
    open var textIsScrollable: Bool = false
    open var textChangingHandler: ((String) -> Void)?
    open var textChangedHandler: ((String) -> Void)?
    open var attributedTextChangedHandler: ((NSAttributedString) -> Void)?
    open var textViewDelegate: UITextViewDelegate?

    /// Auto detect language and set text alignment accordingly. Default is true
    open var autodetectRTLTextAlignment: Bool = true

    /// If set, auto detect the number of characters fitting the boundaries of the text view and truncate the text, then add the given string at the end.
    open var autodetectTextSizeFittingAndTruncateWithString: NSAttributedString?
}
