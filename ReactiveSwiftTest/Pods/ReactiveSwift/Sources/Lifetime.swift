import Foundation
import enum Result.NoError

/// Represents the lifetime of an object, and provides a hook to observe when
/// the object deinitializes.
/// 代表一个对象的生命周期，当对象被析构时，为观察者提供了一个回
public final class Lifetime {

	/// Lifetime的工厂方法
	///
	/// - Returns: Lifetime的对象以及该Lifetime对象所对应的Token对象
	public static func make() -> (lifetime: Lifetime, token: Token) {
		let token = Token()
		return (Lifetime(token), token)
	}

	/// 创建一个已经结束的生命周期
	public static var empty: Lifetime {
		return Lifetime(ended: Signal.empty)
	}
    
    /// 接收Token对象的便利构造器
    ///
    /// - Parameter token: Token对象
    public convenience init(_ token: Token) {
        self.init(ended: token.ended)
    }
    
    /// 用来存储Token对象中的ended信号量
    public let ended: Signal<(), NoError>
    
    /// 参数为Signal类型的构造器
    ///
    /// - Parameter signal: <#signal description#>
    private init(ended signal: Signal<(), NoError>) {
        ended = signal
    }
	

    /// 往ended信号量中添加一个观察者，该观察者之监听
    /// isTerminating （.failed, .completed, .interrupted）事件
    /// - Parameter action: isTerminating事件对外的闭包回调
    /// - Returns: <#return value description#>
    @discardableResult
	public func observeEnded(_ action: @escaping () -> Void) -> Disposable? {
        
		return ended.observe { event in
            
			if event.isTerminating {
				action()
			}
            
		}
        
	}
    
    deinit {
        print("Lifetime的析构函数")
    }
    
	/// 其中就是一个信号量以及信号量负责发送消息的Observer
	/// 当Token被释放时，Observer会发送completed事件
	public final class Token {
		/// A signal that sends a Completed event when the lifetime ends.
		fileprivate let ended: Signal<(), NoError>

		private let endedObserver: Signal<(), NoError>.Observer

		public init() {
			(ended, endedObserver) = Signal.pipe()
		}

        //在Token的析构函数中发送Completed方法
		deinit {
            print("Token的析构函数")
			endedObserver.sendCompleted()
		}
	}
}
