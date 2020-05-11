export declare enum WXShareScene {
  /**
   *  聊天界面
   **/
  WXSceneSession = 0,
  /**
   *  朋友圈
   **/
  WXSceneTimeline = 1,
  /**
   *  收藏
   **/
  WXSceneFavorite = 2,
  /**
   *  指定联系人（须填写 openUserId ）
   */
  WXSceneSpecifiedSession = 3,
}
export declare enum WXShareType {
  WXShareTypeText = 0,
  WXShareTypeImage = 1,
  WXShareTypeMusic = 2,
  WXShareTypeVideo = 3,
  WXShareTypeWeb = 4,
  WXShareTypeMiniProgram = 5,
}
export declare enum WXMiniProgramType {
  /**
   *  正式版
   */
  WXMiniProgramTypeRelease = 0,
  /**
   *  开发版
   */
  WXMiniProgramTypeTest = 1,
  /**
   *  体验版
   */
  WXMiniProgramTypePreview = 2,
}
export interface WXBaseReq {
  /**
   * @iOS 由用户微信号和AppID组成的唯一标识，需要校验微信用户是否换号登录时填写
   * @Android 不明
   */
  openId?: string;
  /**
   * @Android
   */
  transaction?: string;
}
export interface ShareBaseReq extends WXBaseReq {
  scene: WXShareScene;
  /**
   * 接收消息的用户的openid。仅在 scene 为 WXSceneSpecifiedSession 时生效。
   */
  userOpenId?: string;
}
export interface ShareMediaReq extends ShareBaseReq {
  title: string;
  description: string;
  thumbUrl: string;
}
export interface ShareTextReq extends ShareBaseReq {
  type: WXShareType.WXShareTypeText;
  text: string;
}
export interface ShareImageReq extends ShareMediaReq {
  type: WXShareType.WXShareTypeImage;
  imageUrl: string;
}
export interface ShareMusicReq extends ShareMediaReq {
  type: WXShareType.WXShareTypeMusic;
  musicUrl: string;
  musicLowBandUrl?: string;
  musicDataUrl?: string;
  musicLowBandDataUrl?: string;
}
export interface ShareVideoReq extends ShareMediaReq {
  type: WXShareType.WXShareTypeVideo;
  videoUrl: string;
  videoLowBandUrl?: string;
}
export interface ShareWebReq extends ShareMediaReq {
  type: WXShareType.WXShareTypeWeb;
  webpageUrl: string;
}
export interface ShareMiniProgramReq extends ShareMediaReq {
  type: WXShareType.WXShareTypeMiniProgram;
  webpageUrl: string;
  userName: string;
  path: string;
  hdImageUrl: string;
  withShareTicket: boolean;
  miniProgramType: WXMiniProgramType;
}
export declare type WXShareReq =
  | ShareTextReq
  | ShareImageReq
  | ShareMusicReq
  | ShareVideoReq
  | ShareWebReq
  | ShareMiniProgramReq;
export interface WXPayReq extends WXBaseReq {
  /** 商家向财付通申请的商家id */
  partnerId: string;
  /** 预支付订单 */
  prepayId: string;
  /** 随机串，防重发 */
  nonceStr: string;
  /** 时间戳，防重发 */
  timeStamp: string;
  /** 商家根据财付通文档填写的数据和签名 */
  package: string;
  /** 商家根据微信开放平台文档对数据做的签名 */
  sign: string;
}
export interface WXLaunchMiniProgramReq extends WXBaseReq {
  userName: string;
  path?: string;
  miniProgramType: WXMiniProgramType;
}
export interface WXSendAuthReq extends WXBaseReq {
  /**
   * 外部应用请求的权限范围
   * **注意：限制长度不超过1KB**
   */
  scope: string;
  /**
   * 外部应用本身用来标识其请求的唯一性，验证完成后，将由微信终端回传
   * **注意：限制长度不超过1KB**
   */
  state: string;
}
export declare enum WXErrCode {
  /** 成功 */
  WXSuccess = 0,
  /** 普通错误类型 */
  WXErrCodeCommon = -1,
  /** 用户点击取消并返回 */
  WXErrCodeUserCancel = -2,
  /** 发送失败 */
  WXErrCodeSentFail = -3,
  /** 授权失败 */
  WXErrCodeAuthDeny = -4,
  /** 微信不支持 */
  WXErrCodeUnsupported = -5,
}
export interface WXBaseResp {
  errCode: WXErrCode;
  errStr?: string;
  /**
   * @Android
   */
  openId?: string;
  /**
   * @Android
   */
  transaction?: string;
}
export interface WXShareResp extends WXBaseResp {
  /**
   * @iOS
   */
  lang?: string;
  /**
   * @iOS
   */
  country?: string;
}
export interface WXPayResp extends WXBaseResp {
  /**
   * 微信终端返回给第三方的关于支付结果的结构体
   */
  returnKey?: string;
  /**
   * @Android
   */
  prepayId?: string;
  /**
   * @Android
   */
  extData?: string;
}
export interface WXLaunchMiniProgramResp extends WXBaseResp {
  extMsg?: string;
}
export interface WXSendAuthResp extends WXBaseResp {
  /**
   * 授权的code，授权失败时返回null
   */
  code?: string;
  /**
   * @see {@link WXSendAuthReq}
   */
  state?: string;
  lang?: string;
  country?: string;
  /**
   * 只用在 scope:[snsapi_wxaapp_info], 授权成功为true, 否则为false
   * @Android
   */
  authResult?: boolean;
  /**
   * @Android
   */
  url?: string;
}
