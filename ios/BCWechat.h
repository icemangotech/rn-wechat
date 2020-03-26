#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLinkingManager.h>
#import <React/RCTImageLoaderProtocol.h>
#import "WXApi.h"
#import "WXApiObject.h"

typedef NS_ENUM(NSInteger, WXShareType) {
    WXShareTypeText        = 0,
    WXShareTypeImage       = 1,
    WXShareTypeMusic       = 2,
    WXShareTypeVideo       = 3,
    WXShareTypeWeb         = 4,
    WXShareTypeMiniProgram = 5,
};

@interface BCWechat : RCTEventEmitter <RCTBridgeModule, WXApiDelegate>

@property (nullable) NSString* appId;

@property (nullable) RCTPromiseResolveBlock sendResolveBlock;
@property (nullable) RCTPromiseRejectBlock sendRejectBlock;

@property (nullable) RCTPromiseResolveBlock payResolveBlock;

@end
