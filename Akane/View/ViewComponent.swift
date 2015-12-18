//
// This file is part of Akane
//
// Created by JC on 09/11/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation

var ViewComponentPresenterAttr = "ViewComponentPresenterAttr"

public protocol ViewComponent : class {
    func bindings(observer: ViewObserver, viewModel: AnyObject)
}

extension ViewComponent where Self: UIView {
    static func componentControllerClass() -> ComponentViewController<Self>.Type {
        return ComponentViewController.self
    }
}