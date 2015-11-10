/// Block type used for passing the permission state.
/// @param granted Whether Nearby permission is currently granted.
typedef void (^GNSPermissionHandler)(BOOL granted);

/// This class lets you check the permission state of Nearby for the app on the current device.  If
/// the user has not opted into Nearby, publications and subscriptions will not function.
@interface GNSPermission : NSObject

/// Initializes the permission object with a handler that is called whenever the permission state
/// changes.  The handler lets the app keep its UI in sync with the permission state.
/// @param handler The permission granted handler
- (instancetype)initWithChangedHandler:(GNSPermissionHandler)changedHandler;

/// Whether Nearby permission is currently granted for the app on this device.
+ (BOOL)isGranted;
+ (void)setGranted:(BOOL)granted;

@end
