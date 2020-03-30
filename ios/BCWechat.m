#import "BCWechat.h"

// Define error messages
#define INVOKE_FAILED (@"WeChat API invoke returns false.")

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)
#define BC_READ_ASSIGN(object, key) object.key = data[NSStringize(key)]

static NSString *const kOpenURLNotification = @"RCTOpenURLNotification";

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

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:kOpenURLNotification object:nil];
    }
    return self;
}

- (void)dealloc {
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
    resolve(@([WXApi isWXAppSupportApi]));
}

RCT_EXPORT_METHOD(isWXAppInstalled:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    resolve(@([WXApi isWXAppInstalled]));
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

#pragma mark - Share

RCT_EXPORT_METHOD(shareData: (NSDictionary*)data :(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    self.sendResolveBlock = resolve;
    self.sendRejectBlock = reject;

    NSString* thumbnailUrl = data[@"thumbUrl"];

    if (thumbnailUrl.length) {
        [self loadImageFromURLString:thumbnailUrl completionBlock:^(NSError *error, UIImage *image) {
            [self shareData:data withThumbnail:image];
        }];
    } else {
        [self shareData:data withThumbnail:nil];
    }
}

- (void)shareData: (NSDictionary*)data withThumbnail:(UIImage*)thumbnail {
    WXShareType type = [data[@"type"] integerValue];
    int scene = (int)[data[@"scene"] integerValue];
    NSString* user = data[@"userOpenId"];

    if (type == WXShareTypeText) {
        [self shareTextMessage:(NSString *)data[@"text"] atScene:scene toUser: user];
    } else {
        WXMediaMessage* message = [WXMediaMessage message];
        BC_READ_ASSIGN(message, title);
        BC_READ_ASSIGN(message, description);
        [message setThumbImage:thumbnail];

        switch (type) {
            case WXShareTypeImage:
            {
                NSString* imageUrl = data[@"imageUrl"];
                [self loadImageFromURLString:imageUrl completionBlock:^(NSError *error, UIImage *image) {

                    if (!image) {
                        [self rejectSend:nil :@"Image Content Load Fail" :nil];
                    } else {
                        WXImageObject* imageObject = [WXImageObject object];
                        imageObject.imageData = UIImagePNGRepresentation(image);

                        message.mediaObject = imageObject;

                        [self shareMediaMessage: (WXMediaMessage*)message atScene:scene toUser: user];
                    }
                }];
                break;
            }
            case WXShareTypeWeb:
            {
                WXWebpageObject* webpageObject = [WXWebpageObject object];
                BC_READ_ASSIGN(webpageObject, webpageUrl);

                message.mediaObject = webpageObject;

                [self shareMediaMessage: (WXMediaMessage*)message atScene:scene toUser: user];
                break;
            }
            case WXShareTypeMusic:
            {
                WXMusicObject* musicObject = [WXMusicObject object];
                BC_READ_ASSIGN(musicObject, musicUrl);
                BC_READ_ASSIGN(musicObject, musicLowBandUrl);
                BC_READ_ASSIGN(musicObject, musicDataUrl);
                BC_READ_ASSIGN(musicObject, musicLowBandDataUrl);

                message.mediaObject = musicObject;

                [self shareMediaMessage: (WXMediaMessage*)message atScene:scene toUser: user];
                break;
            }
            case WXShareTypeVideo:
            {
                WXVideoObject* videoObject = [WXVideoObject object];
                BC_READ_ASSIGN(videoObject, videoUrl);
                BC_READ_ASSIGN(videoObject, videoLowBandUrl);

                message.mediaObject = videoObject;

                [self shareMediaMessage: (WXMediaMessage*)message atScene:scene toUser: user];
                break;
            }
            case WXShareTypeMiniProgram:
            {
                NSString* hdImageUrl = data[@"hdImageUrl"];
                [self loadImageFromURLString:hdImageUrl completionBlock:^(NSError *error, UIImage *image) {
                    WXMiniProgramObject* mpObject = [WXMiniProgramObject object];
                    BC_READ_ASSIGN(mpObject, webpageUrl);
                    BC_READ_ASSIGN(mpObject, userName);
                    BC_READ_ASSIGN(mpObject, path);
                    BC_READ_ASSIGN(mpObject, withShareTicket);
                    mpObject.miniProgramType = [data[@"miniProgramType"] unsignedIntegerValue];
                    mpObject.hdImageData = UIImagePNGRepresentation(image);

                    message.mediaObject = mpObject;

                    [self shareMediaMessage: (WXMediaMessage*)message atScene:scene toUser: user];
                }];

                break;
            }
            default:
                break;
        }
    }
}

- (void)shareTextMessage: (NSString*)text
                 atScene: (int)scene
                  toUser: (NSString*)user
{
    SendMessageToWXReq* req = [SendMessageToWXReq new];

    req.bText = YES;
    req.scene = scene;
    req.text = text;
    req.toUserOpenId = user;

    [self sendMessageReq:req];
}

- (void)shareMediaMessage: (WXMediaMessage*)message
                  atScene: (int)scene
                   toUser: (NSString*)user
{

    SendMessageToWXReq* req = [SendMessageToWXReq new];

    req.bText = NO;
    req.scene = scene;
    req.message = message;
    req.toUserOpenId = user;

    [self sendMessageReq:req];
}

- (void)sendMessageReq: (SendMessageToWXReq*)req {
    [WXApi sendReq:req completion:^(BOOL success) {
        if (!success) {
            [self rejectSend:nil :INVOKE_FAILED :nil];
        }
    }];
}

- (void)resolveSend: (id)result {
    if (self.sendResolveBlock) {
        self.sendResolveBlock(result);
    }
    self.sendResolveBlock = nil;
    self.sendRejectBlock = nil;
}

- (void)rejectSend: (NSString*)code :(NSString*)reason :(NSError*)error {
    if (self.sendRejectBlock) {
        self.sendRejectBlock(code, reason, error);
    }
    self.sendRejectBlock = nil;
    self.sendResolveBlock = nil;
}

- (void)loadImageFromURLString: (NSString*)urlString completionBlock:(RCTImageLoaderCompletionBlock)callback {
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* imageRequest = [NSURLRequest requestWithURL:url];
    [[self.bridge moduleForName:@"ImageLoader"] loadImageWithURLRequest:imageRequest size:CGSizeMake(100, 100) scale:1 clipped:NO resizeMode:RCTResizeModeStretch progressBlock:nil partialLoadBlock:nil completionBlock:callback];
}

#pragma mark - Pay

RCT_EXPORT_METHOD(pay: (NSDictionary*)data :(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    PayReq* req = [PayReq new];
    
    BC_READ_ASSIGN(req, openID);
    
    BC_READ_ASSIGN(req, partnerId);
    BC_READ_ASSIGN(req, prepayId);
    BC_READ_ASSIGN(req, nonceStr);
    BC_READ_ASSIGN(req, package);
    BC_READ_ASSIGN(req, sign);
    req.timeStamp = [data[@"timeStamp"] unsignedIntValue];

    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            self.payResolveBlock = resolve;
        } else {
            reject(nil, INVOKE_FAILED, nil);
        }
    }];

}

#pragma mark - Launch MiniProgram

RCT_EXPORT_METHOD(launchMiniProgram: (NSDictionary*)data
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    WXLaunchMiniProgramReq* req = [WXLaunchMiniProgramReq new];
    
    BC_READ_ASSIGN(req, openID);
    
    BC_READ_ASSIGN(req, userName);
    BC_READ_ASSIGN(req, path);
    req.miniProgramType = [data[@"miniProgramType"] unsignedIntegerValue];

    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            self.launchResolveBlock = resolve;
        } else {
            reject(nil, INVOKE_FAILED, nil);
        }
    }];
}

#pragma mark - Send Auth Request

RCT_EXPORT_METHOD(sendAuthRequest: (NSDictionary*)data
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    SendAuthReq* req = [SendAuthReq new];
    
    BC_READ_ASSIGN(req, openID);
    
    BC_READ_ASSIGN(req, state);
    BC_READ_ASSIGN(req, scope);

    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            self.sendAuthResolveBlock = resolve;
        } else {
            reject(nil, INVOKE_FAILED, nil);
        }
    }];
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req
{

}

- (void)onResp:(BaseResp *)r
{
    NSMutableDictionary* result = @{
        @"errCode": @(r.errCode)
        // TODO check what is r.type
    }.mutableCopy;

    result[@"errStr"] = r.errStr;

    if ([r isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp* resp = (SendMessageToWXResp*)r;

        result[@"lang"] = resp.lang;
        result[@"country"] = resp.country;

        [self resolveSend: result];
    } else if ([r isKindOfClass:[PayResp class]]) {
        PayResp* resp = (PayResp*)r;

        result[@"returnKey"] = resp.returnKey;

        if (self.payResolveBlock) {
            self.payResolveBlock(result);
        }

        self.payResolveBlock = nil;
    } else if ([r isKindOfClass:[WXLaunchMiniProgramResp class]]) {
        WXLaunchMiniProgramResp* resp = (WXLaunchMiniProgramResp*)r;

        result[@"extMsg"] = resp.extMsg;

        if (self.launchResolveBlock) {
            self.launchResolveBlock(result);
        }

        self.launchResolveBlock = nil;
    } else if ([r isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp* resp = (SendAuthResp*)r;

        result[@"code"] = resp.code;
        result[@"state"] = resp.state;
        result[@"lang"] = resp.lang;
        result[@"country"] = resp.country;

        if (self.sendAuthResolveBlock) {
            self.sendAuthResolveBlock(result);
        }
    }
}

#pragma mark - RCTBridgeModule

- (NSArray<NSString *> *)supportedEvents
{
  return @[];
}

@end
