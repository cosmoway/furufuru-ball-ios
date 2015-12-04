<img src="logo_nearby_color_2x_web_48dp.png" width=96 height=96 alt="Nearby Logo" />

# Nearby Messages

Allow your users to find nearby devices and share messages in a way that’s as
frictionless as a conversation. This enables rich interactions such as as
collaborative editing, forming a group, voting, or broadcasting a resource.

The Nearby Messages API is available for Android and iOS (beta), allowing for
seamless cross-platform experiences.

## Usage

### Creating a Message Manager

This code creates a message manager object, which lets you publish and
subscribe.  Message exchange is unauthenticated, so you will need to supply a
public API key for iOS.  You can create one using the [developer console]
(https://console.developers.google.com/) entry for your project.

```objective-c
GNSMessageManager *messageManager =
    [[GNSMessageManager alloc] initWithAPIKey:@"<insert API key here>"];
```

### Publishing a Message

This code publishes a message containing your email address.  The publication is
active as long as the publication object exists; release it to stop publishing.

```objective-c
NSData *content = [myEmailAddress dataUsingEncoding:NSUTF8StringEncoding];
id<GNSPublication> publication =
    [messageManager publicationWithMessage:[GNSMessage messageWithContent:content]];
```

### Subscribing for Messages

This code subscribes to all email addresses shared by the above publication.
The subscription is active as long as the subscription objects exists; release
it to stop subscribing.

The message found handler is called when nearby devices that are publishing
messages are discovered.  The message lost handler is called when a published
identity is no longer observed (because the device has gone out of range or is
no longer publishing the message).

```objective-c
id<GNSSubscription> subscription =
    [messageManager subscriptionWithMessageFoundHandler:^(GNSMessage *message) {
      // Add the identity string to a list for display
    }
    messageLostHandler:^(GNSMessage *message) {
      // Remove the identity string from the list
    }];
```

### Tracking the Nearby permission state

The user must give permission before device discovery will work.  This is called
the permission state.

On the first call to create a publication or subscription, a permission consent
dialog will be automatically displayed, and the user can approve or deny.  If
the user approves, all is well.  If the user denies, device discovery will not
work.  In this case, your app should show a message in the UI to remind the user
why it’s not working.  The permission state is stored in NSUserDefaults.

Your app can subscribe to the permission state in order to keep its UI in sync.
Here’s how:

```objective-c
_nearbyPermission = [[GNSPermission alloc] initWithChangedHandler:^(BOOL granted) {
  // Update the UI here
}];
```

Your app should provide a way to change the permission state; for example, a
toggle switch on a settings page.  Here’s an example of how it can get & set the
permission state.

Note: The app should set the permission state only in response to the user
action of toggling it on or off in the UI.

```objective-c
BOOL permissionState = [GNSPermission isGranted];
[GNSPermission setGranted:!permissionState];  // toggle the state
```

### Tracking user settings that affect Nearby

If the user has denied microphone permission or has turned Bluetooth off, Nearby
will not work as well, or may not work at all.  Your app should show a message
in these cases, alerting the user that Nearby’s operations are being hindered.
You can track the status of these user settings by passing in handlers when you
create the message manager.  Here’s how:

```objective-c
GNSMessageManager *messageManager = [[GNSMessageManager alloc]
    initWithAPIKey:kMyAPIKey
       paramsBlock:^(GNSMessageManagerParams *params) {
         params.microphonePermissionErrorHandler = ^(BOOL hasError) {
           // Update the UI here
         };
         params.bluetoothPowerErrorHandler = ^(BOOL hasError) {
           // Update the UI here
         };
}];
```

### Scanning for Beacons

By default, subscriptions do not scan for beacons.  To scan for beacons, enable
it in the GNSStrategy, and pass a namespace and type into the subscription
parameters.  Here’s an example:

```objective-c
GNSStrategy *beaconStrategy = [GNSStrategy
    strategyWithParamsBlock:^(GNSStrategyParams *params) {
      params.includeBLEBeacons = YES;
      params.discoveryMediums = kGNSDiscoveryMediumsBLE;
    }];
    GNSSubscriptionParams *beaconParams = [GNSSubscriptionParams
        paramsWithMessageNamespace:@“com.mycompany.mybeaconservice"
                              type:@“mybeacontype"
                          strategy:beaconStrategy];
    _beaconSubscription = [_messageManager subscriptionWithParams:beaconParams
                                              messageFoundHandler:myMessageFoundHandler
                                               messageLostHandler:myMessageLostHandler];
```

### Controlling the Mediums used for Discovery

By default, all mediums (audio and Bluetooth) are used for discovery of nearby
devices.  In some cases, your app may need to use only one of the mediums, and
it may not need to do both broadcasting and scanning on that medium.

For instance, an app that is designed to connect to a set-top box that’s
broadcasting on audio only needs to scan on audio to discover it.  Here’s how
the app can publish a message to that set-top box using only audio scanning for
discovery:

```objective-c
GNSStrategy *strategy = [GNSStrategy
    strategyWithParamsBlock:^(GNSStrategyParams *params) {
      params.discoveryMediums = kGNSDiscoveryMediumsAudio;
      params.discoveryMode = kGNSDiscoveryModeScan;
    }];
_publication = [_messageManager publicationWithParams:
    [GNSPublicationParams paramsWithMessage:message strategy:strategy]];
```

### Enabling Debug Logging

Debug logging can be useful for tracking down problems that you may encounter
when integrating Nearby Messages into your app.  It logs significant internal
events that can help us debug most problems.  To enable debug logging:

```objective-c
[GNSMessageManager setDebugLoggingEnabled:YES];
```

## Installation

[CocoaPods](http://cocoapods.org/) is the recommended installation method.  Add
the following line to your project's Podfile:

```ruby
pod 'NearbyMessages'
```

## License

See the [Nearby](https://developers.google.com/nearby) developer site for license details.
