#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLinkingManager.h>
#import <React/RCTImageLoaderProtocol.h>
#import "WXApi.h"

@interface BCWechat : RCTEventEmitter <RCTBridgeModule, WXApiDelegate>

@property (nullable) NSString* appId;

@property (nullable) RCTPromiseResolveBlock sendResolve;
@property (nullable) RCTPromiseRejectBlock sendReject;

@end
