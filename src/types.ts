export enum WXShareScene {
  /**
   *  聊天界面
   **/
  WXSceneSession,
  /**
   *  朋友圈
   **/
  WXSceneTimeline,
  /**
   *  收藏
   **/
  WXSceneFavorite,
}

export enum WXShareType {
  WXShareTypeText,
  WXShareTypeImage,
  WXShareTypeMusic,
  WXShareTypeVideo,
  WXShareTypeWeb,
  WXShareTypeMiniProgram,
}

export enum WXMiniProgramType {
  /**
   *  正式版
   */
  WXMiniProgramTypeRelease,
  /**
   *  开发版
   */
  WXMiniProgramTypeTest,
  /**
   *  体验版
   */
  WXMiniProgramTypePreview,
}

export interface ShareBaseReq {
  scene: WXShareScene;
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

export type WXShareReq =
  | ShareTextReq
  | ShareImageReq
  | ShareMusicReq
  | ShareVideoReq
  | ShareWebReq
  | ShareMiniProgramReq;

export enum WXErrCode {
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
}

export interface WXShareResp extends WXBaseResp {
  lang?: string;
  country?: string;
}
