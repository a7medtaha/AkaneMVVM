//
// This file is part of Akane
//
// Created by JC on 01/11/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation
import Bond

/**
 Minimalistic API tailored to interact wiht a ```Observation``` from a view.

 Restricted accesses/methods are intended: if you face yourself as being stuck because of the small API, then it probably
 means you need to put your code inside a ```ComponentViewModel``` or a ```Converter``` instead.

*/
public class ObservationWrapper<E> {
    public typealias Element = E

    public private(set) var value: E!

    internal let event: EventProducer<E>
    private let disposeBag: DisposeBag

    internal convenience init<T:Observation where T.Element == E>(observable:T, disposeBag: DisposeBag) {
        let internalObservable = Bond.Observable<E>(observable.value)

        disposeBag.addDisposable(
            observable.observe { [unowned internalObservable] value in
                internalObservable.next(value)
            }
        )

        self.init(event: internalObservable, disposeBag: disposeBag)
    }

    internal init(event: EventProducer<E>, disposeBag: DisposeBag) {
        self.event = event
        self.disposeBag = disposeBag
        self.value = nil

        self.event.observe { [weak self] value in
            self?.value = value
        }
    }

    /// Bind the observation value to a bindable class
    /// - parameter bindable: the bindable item. Should be a view attribute, like a label text attribute.
    public func bindTo<T: Bindable where T.Element == Element>(bindable: T) {
        let next = bindable.advance()

        self.onBind({ value in
            // we can safely unwrap bc 1st closure return us Element?, while we indeed have Element
            next(value!)
        })
    }

    /// Bind the observation value to a optional bindable class
    /// - parameter bindable: the optional bindable item. If nil nothing happens
    public func bindTo<T: Bindable where T.Element == Element?>(bindable: T) {
         self.onBind(bindable.advance())
    }

    public func combine<T: Observation>(observables: T...) -> Self {
        return self
    }

    /// Convert the observation value into a new value by applying the argument converter
    /// - parameter converter: the converter type to use to transform the observation value
    /// - returns: a new ObservationWrapper whose observation is the current converted observation value
    public func convert<T: Converter where T.ValueType == Element>(converter: T.Type) -> ObservationWrapper<T.ConvertValueType> {
        let nextEvent = self.event.map { (value:Element) in
            return converter.init().convert(value)
        }

        return ObservationWrapper<T.ConvertValueType>(event: nextEvent, disposeBag: self.disposeBag)
    }

    public func convert<T: protocol<Converter, ConverterOption> where T.ValueType == Element>(converter: T.Type, options:() -> T.ConvertOptionType) -> ObservationWrapper<T.ConvertValueType> {
        let nextEvent = self.event.map { (value:Element) in
            return converter.init(options: options()).convert(value)
        }

        return ObservationWrapper<T.ConvertValueType>(event: nextEvent, disposeBag: self.disposeBag)
    }

    public func convertBack<T: ConverterReverse where T.ConvertValueType == Element>(converter: T.Type) -> ObservationWrapper<T.ValueType> {
        let nextEvent = self.event.map { (value:Element) in
            return converter.init().convertBack(value)
        }

        return ObservationWrapper<T.ValueType>(event: nextEvent, disposeBag: self.disposeBag)
    }

    public func convertBack<T: protocol<ConverterReverse, ConverterOption> where T.ConvertValueType == Element>(converter: T.Type, options:() -> T.ConvertOptionType) -> ObservationWrapper<T.ValueType> {
        let nextEvent = self.event.map { (value:Element) in
            return converter.init(options: options()).convertBack(value)
        }

        return ObservationWrapper<T.ValueType>(event: nextEvent, disposeBag: self.disposeBag)
    }

    private func onBind(bind: Element? -> Void) {
        let disposable = self.event.observe { value in
            bind(value)
        }

        self.disposeBag.addDisposable(BondDisposeAdapter(disposable))
    }
}