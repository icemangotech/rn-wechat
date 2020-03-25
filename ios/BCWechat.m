#import "BCWechat.h"

// Define error messages
#define INVOKE_FAILED (@"WeChat API invoke returns false.")

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)
#define BC_READ_ASSIGN(object, key) object.key = data[NSStringize(key)]

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
    self.sendResolveBlock = resolve;
    self.sendRejectBlock = reject;

    NSString* thumbnailUrl = data[@"thumbnailUrl"];

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
    int scene = (int)data[@"scene"];

    if (type == WXShareTypeText) {
        [self shareTextMessage:(NSString *)data[@"text"] to:scene];
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
                    WXImageObject* imageObject = [WXImageObject object];
                    imageObject.imageData = UIImagePNGRepresentation(image);

                    [self shareMediaMessage:imageObject to:scene];
                }];
                break;
            }
            case WXShareTypeWeb:
            {
                WXWebpageObject* webpageObject = [WXWebpageObject object];
                BC_READ_ASSIGN(webpageObject, webpageUrl);

                [self shareMediaMessage:webpageObject to:scene];
                break;
            }
            case WXShareTypeMusic:
            {
                WXMusicObject* musicObject = [WXMusicObject object];
                BC_READ_ASSIGN(musicObject, musicUrl);
                BC_READ_ASSIGN(musicObject, musicLowBandUrl);
                BC_READ_ASSIGN(musicObject, musicDataUrl);
                BC_READ_ASSIGN(musicObject, musicLowBandDataUrl);

                [self shareMediaMessage:musicObject to:scene];
                break;
            }
            case WXShareTypeVideo:
            {
                WXVideoObject* videoObject = [WXVideoObject object];
                BC_READ_ASSIGN(videoObject, videoUrl);
                BC_READ_ASSIGN(videoObject, videoLowBandUrl);

                [self shareMediaMessage:videoObject to:scene];
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
                    mpObject.miniProgramType = (int)data[@"miniProgramType"];
                    mpObject.hdImageData = UIImagePNGRepresentation(image);
                    
                    [self shareMediaMessage:mpObject to:scene];
                }];
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)shareTextMessage: (NSString*)text to: (int)scene {
    SendMessageToWXReq* req = [SendMessageToWXReq new];

    req.bText = YES;
    req.scene = scene;
    req.text = text;

    [self sendReq:req];
}

- (void)shareMediaMessage: (id)mediaObject to: (int)scene {
    WXMediaMessage* message = [WXMediaMessage message];

    message.mediaObject = mediaObject;

    SendMessageToWXReq* req = [SendMessageToWXReq new];

    req.bText = NO;
    req.scene = scene;
    req.message = message;

    [self sendReq:req];
}

- (void)sendReq: (SendMessageToWXReq*)req {
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


#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req
{

}

- (void)onResp:(BaseResp *)resp
{

}

@end
