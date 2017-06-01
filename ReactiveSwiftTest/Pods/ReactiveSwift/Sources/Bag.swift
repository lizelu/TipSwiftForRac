//
//  Bag.swift
//  ReactiveSwift
//
//  Created by Justin Spahr-Summers on 2014-07-10.
//  Copyright (c) 2014 GitHub. All rights reserved.
//


/// 使用RemovalToken类的对象的Hash值来作为Bag中所存储元素的唯一标示符
public final class RemovalToken {}

/// 泛型为Element的Bag结构体
public struct Bag<Element> {

	/// 使用ContiguousArray数组来存储Bag中的元素
	fileprivate var elements: ContiguousArray<BagElement<Element>> = []

	public init() {}
    
    /// 往Bag中插入元素的方法，确切的说是append（追加）
    ///
    /// - Parameter value: 要Append的元素
    /// - Returns: 该元素在Bag中的唯一标示符
    @discardableResult
	public mutating func insert(_ value: Element) -> RemovalToken {
		let token = RemovalToken()
		let element = BagElement(value: value, token: token)

		elements.append(element)
		return token
	}

    
    /// 通过元素的Token来从Bag容器中删除元素
    ///
    /// - Parameter token: 元素的Token
    public mutating func remove(using token: RemovalToken) {
		let tokenIdentifier = ObjectIdentifier(token)
		// Removal is more likely for recent objects than old ones.
		for i in elements.indices.reversed() {
			if ObjectIdentifier(elements[i].token) == tokenIdentifier {
				elements.remove(at: i)
				break
			}
		}
	}
}


// MARK: - Bag的延展
extension Bag: Collection {
    
	/// Bag索引的类型，此处就是Int类型
	public typealias Index = Array<Element>.Index

	/// 获取开始索引
	public var startIndex: Index {
		return elements.startIndex
	}
	
	/// 获取结束索引，其实就是数组最后一个值的索引+1
	public var endIndex: Index {
		return elements.endIndex
	}

	/// 自定义Bag下标，使其可以通过下标的形式来获取元素
	///
	/// - Parameter index: 相应元素的下标
	public subscript(index: Index) -> Element {
		return elements[index].value
	}

	/// 获取当前索引的下一个索引
	///
	/// - Parameter i: 当前索引
	/// - Returns: 当前索引+1
	public func index(after i: Index) -> Index {
		return i + 1
	}
    
	/// 创建当前Bag的迭代器
	///
	/// - Returns: 返回当前Bag<Element>的迭代器
	public func makeIterator() -> BagIterator<Element> {
		return BagIterator(elements)
	}
}

/// Bag中所存储的对象元素，由Value和Token组成
private struct BagElement<Value> {
	let value: Value
	let token: RemovalToken
}

// MARK: - 存储元素的延展，用于其信息描述
extension BagElement: CustomStringConvertible {
	var description: String {
		return "BagElement(\(value))"
	}
}


/// Bag容器所对应的迭代器
public struct BagIterator<Element>: IteratorProtocol {
	private let base: ContiguousArray<BagElement<Element>>
	private var nextIndex: Int
	private let endIndex: Int

	fileprivate init(_ base: ContiguousArray<BagElement<Element>>) {
		self.base = base
		nextIndex = base.startIndex
		endIndex = base.endIndex
	}

	/// 获取Bag中下一个元素的值
	///
	/// - Returns: 如果有下一个值，则返回，如果没有则返回nil
	public mutating func next() -> Element? {
		let currentIndex = nextIndex

		if currentIndex < endIndex {
			nextIndex = currentIndex + 1
			return base[currentIndex].value
		}

		return nil
	}
}
