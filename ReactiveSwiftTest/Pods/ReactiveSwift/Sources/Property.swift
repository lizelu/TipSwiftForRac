import Foundation
import enum Result.NoError

/// Represents a property that allows observation of its changes.
///
/// Only classes can conform to this protocol, because having a signal
/// for changes over time implies the origin must have a unique identity.
public protocol PropertyProtocol: class, BindingSource {
	associatedtype Value

	var value: Value { get }

    var producer: SignalProducer<Value, NoError> { get }

	var signal: Signal<Value, NoError> { get }
}

extension PropertyProtocol {
	/// Observe the property by sending all of future value changes to the
	/// given `observer` during the given `lifetime`.
	///
	/// - parameters:
	///   - observer: An observer to send the events to.
	///   - lifetime: A lifetime of the observing object.
	@discardableResult
	@available(*, deprecated, message:"Use `take(during:)` and `start` on the property producer instead. `observe(_:during:)` would be removed in ReactiveSwift 2.0.")
	public func observe(_ observer: Observer<Value, NoError>, during lifetime: Lifetime) -> Disposable? {
		return producer.observe(observer, during: lifetime)
	}
}

/// Represents an observable property that can be mutated directly.
public protocol MutablePropertyProtocol: PropertyProtocol, BindingTargetProvider, BindingTargetProtocol {
	/// The current value of the property.
	var value: Value { get set }

	/// The lifetime of the property.
	var lifetime: Lifetime { get }
}

/// Default implementation of `BindingTargetProvider` for mutable properties.
extension MutablePropertyProtocol {
	public var bindingTarget: BindingTarget<Value> {
		return BindingTarget(lifetime: lifetime) { [weak self] in self?.value = $0 }
	}
}

/// Represents a mutable property that can be safety composed by exposing its
/// synchronization mechanic through the defined closure-based interface.
public protocol ComposableMutablePropertyProtocol: MutablePropertyProtocol {
	/// Atomically performs an arbitrary action using the current value of the
	/// variable.
	///
	/// - parameters:
	///   - action: A closure that accepts current property value.
	///
	/// - returns: the result of the action.
	func withValue<Result>(action: (Value) throws -> Result) rethrows -> Result

	/// Atomically modifies the variable.
	///
	/// - parameters:
	///   - action: A closure that accepts old property value and returns a new
	///             property value.
	///
	/// - returns: The result of the action.
	func modify<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result
}

// Property operators.
//
// A composed property is a transformed view of its sources, and does not
// own its lifetime. Its producer and signal are bound to the lifetime of
// its sources.

extension PropertyProtocol {
	/// Lifts a unary SignalProducer operator to operate upon PropertyProtocol instead.
	fileprivate func lift<U>(_ transform: @escaping (SignalProducer<Value, NoError>) -> SignalProducer<U, NoError>) -> Property<U> {
		return Property(self, transform: transform)
	}

	/// Lifts a binary SignalProducer operator to operate upon PropertyProtocol instead.
	fileprivate func lift<P: PropertyProtocol, U>(_ transform: @escaping (SignalProducer<Value, NoError>) -> (SignalProducer<P.Value, NoError>) -> SignalProducer<U, NoError>) -> (P) -> Property<U> {
		return { otherProperty in
			return Property(self, otherProperty, transform: transform)
		}
	}

	/// Maps the current value and all subsequent values to a new property.
	///
	/// - parameters:
	///   - transform: A closure that will map the current `value` of this
	///                `Property` to a new value.
	///
	/// - returns: A property that holds a mapped value from `self`.
	public func map<U>(_ transform: @escaping (Value) -> U) -> Property<U> {
		return lift { $0.map(transform) }
	}

	/// Combines the current value and the subsequent values of two `Property`s in
	/// the manner described by `Signal.combineLatest(with:)`.
	///
	/// - parameters:
	///   - other: A property to combine `self`'s value with.
	///
	/// - returns: A property that holds a tuple containing values of `self` and
	///            the given property.
	public func combineLatest<P: PropertyProtocol>(with other: P) -> Property<(Value, P.Value)> {
		return lift(SignalProducer.combineLatest(with:))(other)
	}

	/// Zips the current value and the subsequent values of two `Property`s in
	/// the manner described by `Signal.zipWith`.
	///
	/// - parameters:
	///   - other: A property to zip `self`'s value with.
	///
	/// - returns: A property that holds a tuple containing values of `self` and
	///            the given property.
	public func zip<P: PropertyProtocol>(with other: P) -> Property<(Value, P.Value)> {
		return lift(SignalProducer.zip(with:))(other)
	}

	/// Forward events from `self` with history: values of the returned property
	/// are a tuple whose first member is the previous value and whose second
	/// member is the current value. `initial` is supplied as the first member
	/// when `self` sends its first value.
	///
	/// - parameters:
	///   - initial: A value that will be combined with the first value sent by
	///              `self`.
	///
	/// - returns: A property that holds tuples that contain previous and
	///            current values of `self`.
	public func combinePrevious(_ initial: Value) -> Property<(Value, Value)> {
		return lift { $0.combinePrevious(initial) }
	}

	/// Forward only those values from `self` which do not pass `isRepeat` with
	/// respect to the previous value.
	///
	/// - parameters:
	///   - isRepeat: A predicate to determine if the two given values are equal.
	///
	/// - returns: A property that does not emit events for two equal values
	///            sequentially.
	public func skipRepeats(_ isRepeat: @escaping (Value, Value) -> Bool) -> Property<Value> {
		return lift { $0.skipRepeats(isRepeat) }
	}
}

extension PropertyProtocol where Value: Equatable {
	/// Forward only those values from `self` which do not pass `isRepeat` with
	/// respect to the previous value.
	///
	/// - returns: A property that does not emit events for two equal values
	///            sequentially.
	public func skipRepeats() -> Property<Value> {
		return lift { $0.skipRepeats() }
	}
}

extension PropertyProtocol where Value: PropertyProtocol {
	/// Flattens the inner property held by `self` (into a single property of
	/// values), according to the semantics of the given strategy.
	///
	/// - parameters:
	///   - strategy: The preferred flatten strategy.
	///
	/// - returns: A property that sends the values of its inner properties.
	public func flatten(_ strategy: FlattenStrategy) -> Property<Value.Value> {
		return lift { $0.flatMap(strategy) { $0.producer } }
	}
}

extension PropertyProtocol {
	/// Maps each property from `self` to a new property, then flattens the
	/// resulting properties (into a single property), according to the
	/// semantics of the given strategy.
	///
	/// - parameters:
	///   - strategy: The preferred flatten strategy.
	///   - transform: The transform to be applied on `self` before flattening.
	///
	/// - returns: A property that sends the values of its inner properties.
	public func flatMap<P: PropertyProtocol>(_ strategy: FlattenStrategy, transform: @escaping (Value) -> P) -> Property<P.Value> {
		return lift { $0.flatMap(strategy) { transform($0).producer } }
	}

	/// Forward only those values from `self` that have unique identities across
	/// the set of all values that have been held.
	///
	/// - note: This causes the identities to be retained to check for 
	///         uniqueness.
	///
	/// - parameters:
	///   - transform: A closure that accepts a value and returns identity
	///                value.
	///
	/// - returns: A property that sends unique values during its lifetime.
	public func uniqueValues<Identity: Hashable>(_ transform: @escaping (Value) -> Identity) -> Property<Value> {
		return lift { $0.uniqueValues(transform) }
	}
}

extension PropertyProtocol where Value: Hashable {
	/// Forwards only those values from `self` that are unique across the set of
	/// all values that have been seen.
	///
	/// - note: This causes the identities to be retained to check for uniqueness.
	///         Providing a function that returns a unique value for each sent
	///         value can help you reduce the memory footprint.
	///
	/// - returns: A property that sends unique values during its lifetime.
	public func uniqueValues() -> Property<Value> {
		return lift { $0.uniqueValues() }
	}
}

extension PropertyProtocol {
	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol>(_ a: A, _ b: B) -> Property<(A.Value, B.Value)> where Value == A.Value {
		return a.combineLatest(with: b)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol>(_ a: A, _ b: B, _ c: C) -> Property<(A.Value, B.Value, C.Value)> where Value == A.Value {
		return combineLatest(a, b)
			.combineLatest(with: c)
			.map(repack)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D) -> Property<(A.Value, B.Value, C.Value, D.Value)> where Value == A.Value {
		return combineLatest(a, b, c)
			.combineLatest(with: d)
			.map(repack)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value)> where Value == A.Value {
		return combineLatest(a, b, c, d)
			.combineLatest(with: e)
			.map(repack)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value)> where Value == A.Value {
		return combineLatest(a, b, c, d, e)
			.combineLatest(with: f)
			.map(repack)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value)> where Value == A.Value {
		return combineLatest(a, b, c, d, e, f)
			.combineLatest(with: g)
			.map(repack)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol, H: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value, H.Value)> where Value == A.Value {
		return combineLatest(a, b, c, d, e, f, g)
			.combineLatest(with: h)
			.map(repack)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol, H: PropertyProtocol, I: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value, H.Value, I.Value)> where Value == A.Value {
		return combineLatest(a, b, c, d, e, f, g, h)
			.combineLatest(with: i)
			.map(repack)
	}

	/// Combines the values of all the given properties, in the manner described
	/// by `combineLatest(with:)`.
	public static func combineLatest<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol, H: PropertyProtocol, I: PropertyProtocol, J: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value, H.Value, I.Value, J.Value)> where Value == A.Value {
		return combineLatest(a, b, c, d, e, f, g, h, i)
			.combineLatest(with: j)
			.map(repack)
	}

	/// Combines the values of all the given producers, in the manner described by
	/// `combineLatest(with:)`. Returns nil if the sequence is empty.
	public static func combineLatest<S: Sequence>(_ properties: S) -> Property<[S.Iterator.Element.Value]>? where S.Iterator.Element: PropertyProtocol {
		var generator = properties.makeIterator()
		if let first = generator.next() {
			let initial = first.map { [$0] }
			return IteratorSequence(generator).reduce(initial) { property, next in
				property.combineLatest(with: next).map { $0.0 + [$0.1] }
			}
		}

		return nil
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol>(_ a: A, _ b: B) -> Property<(A.Value, B.Value)> where Value == A.Value {
		return a.zip(with: b)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol>(_ a: A, _ b: B, _ c: C) -> Property<(A.Value, B.Value, C.Value)> where Value == A.Value {
		return zip(a, b)
			.zip(with: c)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D) -> Property<(A.Value, B.Value, C.Value, D.Value)> where Value == A.Value {
		return zip(a, b, c)
			.zip(with: d)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value)> where Value == A.Value {
		return zip(a, b, c, d)
			.zip(with: e)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value)> where Value == A.Value {
		return zip(a, b, c, d, e)
			.zip(with: f)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value)> where Value == A.Value {
		return zip(a, b, c, d, e, f)
			.zip(with: g)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol, H: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value, H.Value)> where Value == A.Value {
		return zip(a, b, c, d, e, f, g)
			.zip(with: h)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol, H: PropertyProtocol, I: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value, H.Value, I.Value)> where Value == A.Value {
		return zip(a, b, c, d, e, f, g, h)
			.zip(with: i)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`.
	public static func zip<A: PropertyProtocol, B: PropertyProtocol, C: PropertyProtocol, D: PropertyProtocol, E: PropertyProtocol, F: PropertyProtocol, G: PropertyProtocol, H: PropertyProtocol, I: PropertyProtocol, J: PropertyProtocol>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J) -> Property<(A.Value, B.Value, C.Value, D.Value, E.Value, F.Value, G.Value, H.Value, I.Value, J.Value)> where Value == A.Value {
		return zip(a, b, c, d, e, f, g, h, i)
			.zip(with: j)
			.map(repack)
	}

	/// Zips the values of all the given properties, in the manner described by
	/// `zip(with:)`. Returns nil if the sequence is empty.
	public static func zip<S: Sequence>(_ properties: S) -> Property<[S.Iterator.Element.Value]>? where S.Iterator.Element: PropertyProtocol {
		var generator = properties.makeIterator()
		if let first = generator.next() {
			let initial = first.map { [$0] }
			return IteratorSequence(generator).reduce(initial) { property, next in
				property.zip(with: next).map { $0.0 + [$0.1] }
			}
		}
		
		return nil
	}
}

extension PropertyProtocol where Value == Bool {
	/// Create a property that computes a logical NOT in the latest values of `self`.
	///
	/// - returns: A property that contains the logial NOT results.
	public func negate() -> Property<Value> {
		return self.lift { $0.negate() }
	}
	
	/// Create a property that computes a logical AND between the latest values of `self`
	/// and `property`.
	///
	/// - parameters:
	///   - property: Property to be combined with `self`.
	///
	/// - returns: A property that contains the logial AND results.
	public func and(_ property: Property<Value>) -> Property<Value> {
		return self.lift(SignalProducer.and)(property)
	}
	
	/// Create a property that computes a logical OR between the latest values of `self`
	/// and `property`.
	///
	/// - parameters:
	///   - property: Property to be combined with `self`.
	///
	/// - returns: A property that contains the logial OR results.
	public func or(_ property: Property<Value>) -> Property<Value> {
		return self.lift(SignalProducer.or)(property)
	}
}

/// A read-only property that can be observed for its changes over time. There
/// are three categories of read-only properties:
///
/// # Constant property
/// Created by `Property(value:)`, the producer and signal of a constant
/// property would complete immediately when it is initialized.
///
/// # Existential property
/// Created by `Property(capturing:)`, it wraps any arbitrary `PropertyProtocol`
/// types, and passes through the behavior. Note that it would retain the
/// wrapped property.
///
/// Existential property would be deprecated when generalized existential
/// eventually lands in Swift.
///
/// # Composed property
/// A composed property presents a composed view of its sources, which can be
/// one or more properties, a producer, or a signal. It can be created using
/// property composition operators, `Property(_:)` or `Property(initial:then:)`.
///
/// It does not own its lifetime, and its producer and signal are bound to the
/// lifetime of its sources. It also does not have an influence on its sources,
/// so retaining a composed property would not prevent its sources from
/// deinitializing.
///
/// Note that composed properties do not retain any of its sources.
public final class Property<Value>: PropertyProtocol {
	private let disposable: Disposable?

	private let _value: () -> Value
	private let _producer: () -> SignalProducer<Value, NoError>
	private let _signal: () -> Signal<Value, NoError>

	public var value: Value {
		return _value()
	}

	public var producer: SignalProducer<Value, NoError> {
		return _producer()
	}

	public var signal: Signal<Value, NoError> {
		return _signal()
	}

	/// Initializes a constant property.
	///
	/// - parameters:
	///   - property: A value of the constant property.
	public init(value: Value) {
		disposable = nil
		_value = { value }
		_producer = { SignalProducer(value: value) }
		_signal = { Signal<Value, NoError>.empty }
	}

	/// Initializes an existential property which wraps the given property.
	///
	/// - note: The resulting property retains the given property.
	///
	/// - parameters:
	///   - property: A property to be wrapped.
	public init<P: PropertyProtocol>(capturing property: P) where P.Value == Value {
		disposable = nil
		_value = { property.value }
		_producer = { property.producer }
		_signal = { property.signal }
	}
    
    /// Initialize a composed property from a producer that promises to send
    /// at least one value synchronously in its start handler before sending any
    /// subsequent event.
    ///
    /// - important: The producer and the signal of the created property would
    ///              complete only when the `unsafeProducer` completes.
    ///
    /// - warning: If the producer fails its promise, a fatal error would be
    ///            raised.
    ///
    /// - parameters:
    ///   - unsafeProducer: The composed producer for creating the property.
    private init(unsafeProducer: SignalProducer<Value, NoError>) {
        // Share a replayed producer with `self.producer` and `self.signal` so
        // they see a consistent view of the `self.value`.
        // https://github.com/ReactiveCocoa/ReactiveCocoa/pull/3042
        let producer = unsafeProducer.replayLazily(upTo: 1)
        
        let atomic = Atomic<Value?>(nil)
        disposable = producer.startWithValues { atomic.value = $0 }
        
        // Verify that an initial is sent. This is friendlier than deadlocking
        // in the event that one isn't.
        guard atomic.value != nil else {
            fatalError("A producer promised to send at least one value. Received none.")
        }
        
        _value = { atomic.value! }
        _producer = { producer }
        _signal = { producer.startAndRetrieveSignal() }
    }
    


	/// Initializes a composed property which reflects the given property.
	///
	/// - note: The resulting property does not retain the given property.
	///
	/// - parameters:
	///   - property: A property to be wrapped.
	public convenience init<P: PropertyProtocol>(_ property: P) where P.Value == Value {
		self.init(unsafeProducer: property.producer)
	}

	/// Initializes a composed property that first takes on `initial`, then each
	/// value sent on a signal created by `producer`.
	///
	/// - parameters:
	///   - initial: Starting value for the property.
	///   - values: A producer that will start immediately and send values to
	///             the property.
	public convenience init(initial: Value, then values: SignalProducer<Value, NoError>) {
		self.init(unsafeProducer: SignalProducer { observer, disposables in
			observer.send(value: initial)
			disposables += values.start(Observer(mappingInterruptedToCompleted: observer))
		})
	}

	/// Initialize a composed property that first takes on `initial`, then each
	/// value sent on `signal`.
	///
	/// - parameters:
	///   - initialValue: Starting value for the property.
	///   - values: A signal that will send values to the property.
	public convenience init(initial: Value, then values: Signal<Value, NoError>) {
		self.init(initial: initial, then: SignalProducer(values))
	}

	/// Initialize a composed property by applying the unary `SignalProducer`
	/// transform on `property`.
	///
	/// - parameters:
	///   - property: The source property.
	///   - transform: A unary `SignalProducer` transform to be applied on
	///     `property`.
	fileprivate convenience init<P: PropertyProtocol>(
		_ property: P,
		transform: @escaping (SignalProducer<P.Value, NoError>) -> SignalProducer<Value, NoError>
	) {
		self.init(unsafeProducer: transform(property.producer))
	}

	/// Initialize a composed property by applying the binary `SignalProducer`
	/// transform on `firstProperty` and `secondProperty`.
	///
	/// - parameters:
	///   - firstProperty: The first source property.
	///   - secondProperty: The first source property.
	///   - transform: A binary `SignalProducer` transform to be applied on
	///             `firstProperty` and `secondProperty`.
	fileprivate convenience init<P1: PropertyProtocol, P2: PropertyProtocol>(_ firstProperty: P1, _ secondProperty: P2, transform: @escaping (SignalProducer<P1.Value, NoError>) -> (SignalProducer<P2.Value, NoError>) -> SignalProducer<Value, NoError>) {
		self.init(unsafeProducer: transform(firstProperty.producer)(secondProperty.producer))
	}
	deinit {
		disposable?.dispose()
	}
}

/// A mutable property of type `Value` that allows observation of its changes.
///
/// Instances of this class are thread-safe.
public final class MutableProperty<Value>: ComposableMutablePropertyProtocol {
    
	private let token: Lifetime.Token                       //标记生命周期的Token
	private let observer: Signal<Value, NoError>.Observer   //发送事件的Observer
	private let atomic: RecursiveAtomic<Value>              //加有递归锁的原子操作

    public var value: Value {  //Property中存储的值
		get {
			return atomic.withValue { $0 }
		}

		set {
			swap(newValue) //atomic.swap(newValue)
		}
	}

	/// The lifetime of the property.
	public let lifetime: Lifetime
	public let signal: Signal<Value, NoError>   //Property中想信号量

	public var producer: SignalProducer<Value, NoError> {   //内置SignalProducer
		return SignalProducer { [atomic, signal] producerObserver, producerDisposable in
			atomic.withValue { value in
				producerObserver.send(value: value)     //获取值时发出value信号量
				producerDisposable += signal.observe(Observer(mappingInterruptedToCompleted: producerObserver))
			}
		}
	}
    
	public init(_ initialValue: Value) {
		(signal, observer) = Signal.pipe()
		token = Lifetime.Token()
		lifetime = Lifetime(token)
		atomic = RecursiveAtomic(initialValue,
		                          name: "org.reactivecocoa.ReactiveSwift.MutableProperty",
		                          didSet: observer.send(value:))  //被赋值后发送Value事件
	}

	/// 赋值
	///
	/// - Parameter newValue: 新值
	/// - Returns: 旧值
	@discardableResult
	public func swap(_ newValue: Value) -> Value {
		return atomic.swap(newValue)
	}

	/// 修改值
	///
	/// - Parameter action: <#action description#>
	/// - Returns: <#return value description#>
	/// - Throws: <#throws value description#>
	@discardableResult
	public func modify<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result {
		return try atomic.modify(action)
	}


	/// 获取值
	///
	/// - Parameter action: <#action description#>
	/// - Returns: <#return value description#>
	/// - Throws: <#throws value description#>
	@discardableResult
	public func withValue<Result>(action: (Value) throws -> Result) rethrows -> Result {
		return try atomic.withValue(action)
	}

	deinit {
		observer.sendCompleted()
	}
}

private extension Observer {
	convenience init(mappingInterruptedToCompleted observer: Observer<Value, Error>) {
		self.init { event in
			switch event {
			case .value, .completed, .failed:
				observer.action(event)
			case .interrupted:
				observer.sendCompleted()
			}
		}
	}
}
