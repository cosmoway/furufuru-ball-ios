@class GNSMessage;
@class GNSStrategy;

/// Publication parameters include a message and strategy for delivery.
/// See the property declarations below for explanations of each parameter.
/// The message is delivered to a nearby device if that device is subscribed to the message's type.
@interface GNSPublicationParams : NSObject

/// The message to publish.  Cannot be nil.
@property(nonatomic, readonly) GNSMessage *message;

/// The strategy to use for publishing the message.  Cannot be nil.
@property(nonatomic, readonly) GNSStrategy *strategy;

/// Publication parameters using the default strategy.
+ (instancetype)paramsWithMessage:(GNSMessage *)message;

/// Publication parameters using the specified strategy.
+ (instancetype)paramsWithMessage:(GNSMessage *)message strategy:(GNSStrategy *)strategy;

@end
