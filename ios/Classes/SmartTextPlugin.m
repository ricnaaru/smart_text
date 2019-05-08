#import "SmartTextPlugin.h"
#import <smart_text/smart_text-Swift.h>

@implementation SmartTextPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSmartTextPlugin registerWithRegistrar:registrar];
}
@end
