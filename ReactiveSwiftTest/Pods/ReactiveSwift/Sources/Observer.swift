//
//  Observer.swift
//  ReactiveSwift
//
//  Created by Andy Matuschak on 10/2/15.
//  Copyright © 2015 GitHub. All rights reserved.
//

/// A protocol for type-constrained extensions of `Observer`.
@available(*, deprecated, message: "The protocol will be removed in a future version of ReactiveSwift. Use Observer directly.")
public protocol ObserverProtocol {
	associatedtype Value
	associatedtype Error: Swift.Error

	/// Puts a `value` event into `self`.
	func send(value: Value)

	/// Puts a failed event into `self`.
	func send(error: Error)

	/// Puts a `completed` event into `self`.
	func sendCompleted()

	/// Puts an `interrupted` event into `self`.
	func sendInterrupted()
}

/// An Observer is a simple wrapper around a function which can receive Events
/// (typically from a Signal).

public final class Observer<Value, Error: Swift.Error> {
    
    //为 Event<Value, Error> -> Void闭包类型定义一个名为Action的别名
	public typealias Action = (Event<Value, Error>) -> Void

    //声明Observer所持有的事件
	public let action: Action

    //构造器，参数为 Event<Value, Error> -> Void 类型的闭包
	public init(_ action: @escaping Action) {
		self.action = action
	}

    //便利构造器，参数为 四个闭包， 根据 Event 的四种事件类型来执行不同的闭包
	public convenience init(
		value: ((Value) -> Void)? = nil,
		failed: ((Error) -> Void)? = nil,
		completed: (() -> Void)? = nil,
		interrupted: (() -> Void)? = nil
	) {
		self.init { event in
			switch event {
			case let .value(v):
				value?(v)               //将事件的值回调出去

			case let .failed(error):
				failed?(error)          //将事件的错误回调出去

			case .completed:
				completed?()

			case .interrupted:
				interrupted?()
			}
		}
	}

	/// Puts a `value` event into `self`.
	///
	/// - parameters:
	///   - value: A value sent with the `value` event.
	public func send(value: Value) {
		action(.value(value))
	}

	/// Puts a failed event into `self`.
	///
	/// - parameters:
	///   - error: An error object sent with failed event.
	public func send(error: Error) {
		action(.failed(error))
	}

	/// Puts a `completed` event into `self`.
	public func sendCompleted() {
		action(.completed)
	}

	/// Puts an `interrupted` event into `self`.
	public func sendInterrupted() {
		action(.interrupted)
	}
}

extension Observer: ObserverProtocol {}
