// NVibeNavigationBridge.m
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(NVibeNavigation, RCTEventEmitter)

RCT_EXTERN_METHOD(getRoute:(NSDictionary *)origin destination:(NSDictionary *)destination callback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(startNavigation:(NSDictionary *)origin destination:(NSDictionary *)destination)
RCT_EXTERN_METHOD(stopNavigation)

RCT_EXTERN_METHOD(test:(NSDictionary *)value)
RCT_EXTERN_METHOD(getData:(NSDictionary *)value)

@end
