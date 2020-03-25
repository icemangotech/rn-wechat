#import "BCWechat.h"

// Define error messages
#define INVOKE_FAILED (@"WeChat API invoke returns false.")

@implementation BCWechat

RCT_EXPORT_MODULE()

- (BOOL)handleOpenURL:(NSNotification *)aNotification
{
    NSString * aURLString =  [aNotification userInfo][@"url"];
    NSURL * aURL = [NSURL URLWithString:aURLString];

    if ([WXApi handleOpenURL:aURL delegate:self])
    {
        return YES;
    } else {
        return NO;
    }
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"RCTOpenURLNotification" object:nil];
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark - Basic

RCT_EXPORT_METHOD(registerApp:(NSString*)appId
                  :(NSString*)universalLink
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    self.appId = appId;
    if ([WXApi registerApp:appId universalLink:universalLink]) {
        resolve(nil);
    } else {
        reject(nil, nil, nil);
    }
}

RCT_EXPORT_METHOD(isWXAppSupportApi:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    if ([WXApi isWXAppSupportApi]) {
        resolve(nil);
    } else {
        reject(nil, nil, nil);
    }
}

RCT_EXPORT_METHOD(getWXAppInstallUrl:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    resolve([WXApi getWXAppInstallUrl]);
}

RCT_EXPORT_METHOD(getApiVersion:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    resolve([WXApi getApiVersion]);
}

RCT_EXPORT_METHOD(openWXApp:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    if ([WXApi openWXApp]) {
        resolve(nil);
    } else {
        reject(nil, nil, nil);
    }
}

RCT_EXPORT_METHOD(shareData: (NSDictionary*)data :(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    SendMessageToWXReq* req = [self extractShareReqFromData:data];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            self.sendResolve = resolve;
            self.sendReject = reject;
        } else {
            reject(nil, INVOKE_FAILED, nil);
        }
    }];
}

- (SendMessageToWXReq*)extractShareReqFromData: (NSDictionary*)data
{
    return nil;
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    
}

@end
