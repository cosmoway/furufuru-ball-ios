///
/// Public interface to the iOS Nearby Messages library.
///
/// This library lets devices that are in close proximity with each other exchange messages, which
/// contain small amounts of data.  When a device publishes a message, nearby devices can receive
/// the message.
///
/// A message has type that can be used as a filter for subscriptions.  When a subscriber's type
/// matches a message published from a nearby device, the message is delivered to it.
///
/// The Messages library uses the Nearby.Messages Apiary service and thus requires that it is
/// enabled for your application in the APIs Console:
///   https://console.developers.google.com

#import "GNSError.h"

@class GNSMessage;
@class GNSPublicationParams;
@class GNSSubscriptionParams;
@class GNSStrategy;

/// Block type used by subscriptions for the message handler.
/// @param message The received message.
typedef void (^GNSMessageHandler)(GNSMessage *message);


/// A publication object represents a message published to nearby devices.  As long as it
/// lives, the messages library will do its best to make sure the message is being published, as
/// long as the required conditions are met (e.g., the app must be in the foreground).  When the
/// publication object is deallocated, the message will no longer be published.
@protocol GNSPublication <NSObject>
@end

/// A subscription object represents the act of subscribing to messages of a certain
/// type from nearby devices.  As long as it lives, the messages library will do its best to
/// deliver messages that match the subscription’s type, as long as the required conditions are
/// met (e.g., the app must be in the foreground).  Message handlers are called when messages are
/// are discovered or lost.  When the subscription object is deallocated, message delivery will
/// cease.
@protocol GNSSubscription <NSObject>
@end


/// Additional parameters for the message manager.
@interface GNSMessageManagerParams : NSObject

/// Show the system alert when Bluetooth is off.  Default is YES.
@property(nonatomic, getter=shouldShowBluetoothPowerAlert) BOOL showBluetoothPowerAlert;

/// The following error handlers are called (on the main thread) when the status of the error
/// changes.  A value of YES implies an error.
/// Microphone permission is denied.
@property(nonatomic, copy) GNSErrorStateHandler microphonePermissionErrorHandler;
/// Bluetooth permission is denied.
@property(nonatomic, copy) GNSErrorStateHandler bluetoothPermissionErrorHandler;
/// Bluetooth is powered off.
@property(nonatomic, copy) GNSErrorStateHandler bluetoothPowerErrorHandler;

@end


/// The message manager lets you create publications and subscriptions.  They are valid only as long
/// as the manager exists.
@interface GNSMessageManager : NSObject

/// Initializes the messages manager.
/// @param apiKey The API key of the app, required to use the Messages service
- (instancetype)initWithAPIKey:(NSString *)apiKey;

/// Initializes the messages manager with additional parameters.
/// @param apiKey The API key of the app, required to use the Messages service
/// @param paramsBlock Use this block to pass additional parameters
- (instancetype)initWithAPIKey:(NSString *)apiKey
                   paramsBlock:(void (^)(GNSMessageManagerParams *))paramsBlock;

/// Publishes a message.  Release the publication object to unpublish the message.
/// @param publicationParams The message and required parameters
/// @return Publication object; release to unpublish
- (id<GNSPublication>)publicationWithMessage:(GNSMessage *)message;

/// Publishes a message with additional parameters.  Release the publication object to unpublish the
/// message.
/// @param publicationParams The message and required parameters
/// @return Publication object; release to unpublish
- (id<GNSPublication>)publicationWithParams:(GNSPublicationParams *)publicationParams;

/// Subscribes to all messages published by your app.  Release it to stop subscribing.  When a new
/// message is received from a nearby device, @messageFoundHandler is called; when the message is
/// no longer heard, @messageLostHandler is called.
/// @param messageFoundHandler Block that's called when a new message is discovered
/// @param messageLostHandler Block that's called when a previously discovered message is lost
/// @return Subscription object; release to cancel the subscription
- (id<GNSSubscription>)subscriptionWithMessageFoundHandler:(GNSMessageHandler)messageFoundHandler
                                        messageLostHandler:(GNSMessageHandler)messageLostHandler;

/// Subscribes to all messages published by your app, with additional parameters.  For instance, you
/// can subscribe to a subset of messages.  Release it to stop subscribing.
/// @param subscriptionParams Subscription parameters
/// @param messageFoundHandler Block that's called when a new message is discovered
/// @param messageLostHandler Block that's called when a previously discovered message is lost
/// @return Subscription object; release to cancel the subscription
- (id<GNSSubscription>)subscriptionWithParams:(GNSSubscriptionParams *)subscriptionParams
                          messageFoundHandler:(GNSMessageHandler)messageFoundHandler
                           messageLostHandler:(GNSMessageHandler)messageLostHandler;

/// Enables or disables debug logging.  When enabled, log messages for internal operations are
/// written to the console to help with debugging, even in release builds. This is useful for
/// debugging problems encountered by 3rd party clients.  By default, it is disabled, even in debug
/// builds.
+ (void)setDebugLoggingEnabled:(BOOL)enabled;

/// Returns the current debug logging state.
+ (BOOL)isDebugLoggingEnabled;

@end
