@class GNSStrategy;

/// Subscription parameters include a message type and a strategy for receipt of messages.
/// See the property descriptions below for explanations of each parameter.  Messages from nearby
/// devices are delivered to this subscription if they match the specified type.
@interface GNSSubscriptionParams : NSObject

/// The namespace of the type to match. The empty string is the default namespace, and is private
/// to each app (or apps sharing a Google Developer Console project).
@property(nonatomic, readonly) NSString *messageNamespace;

/// The type to match. Must not be nil. The empty string is the default type.
@property(nonatomic, readonly) NSString *type;

/// The strategy to use for receiving messages.  Must not be nil.  @see GNSStrategy.
@property(nonatomic, readonly) GNSStrategy *strategy;

/// Subscription parameters using the default strategy.
+ (instancetype)paramsWithMessageType:(NSString *)type;

/// Subscription parameters using the default strategy.
+ (instancetype)paramsWithMessageNamespace:(NSString *)messageNamespace type:(NSString *)type;

/// Subscription parameters using the specified strategy.
+ (instancetype)paramsWithMessageType:(NSString *)type strategy:(GNSStrategy *)strategy;

/// Subscription parameters using the specified strategy.
+ (instancetype)paramsWithMessageNamespace:(NSString *)messageNamespace
                                      type:(NSString *)type
                                  strategy:(GNSStrategy *)strategy;

/// Subscription parameters using the specified strategy.
+ (instancetype)paramsWithStrategy:(GNSStrategy *)strategy;

@end
