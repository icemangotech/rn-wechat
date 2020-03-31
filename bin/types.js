export var WXShareScene;
(function (WXShareScene) {
  /**
   *  聊天界面
   **/
  WXShareScene[(WXShareScene.WXSceneSession = 0)] = 'WXSceneSession';
  /**
   *  朋友圈
   **/
  WXShareScene[(WXShareScene.WXSceneTimeline = 1)] = 'WXSceneTimeline';
  /**
   *  收藏
   **/
  WXShareScene[(WXShareScene.WXSceneFavorite = 2)] = 'WXSceneFavorite';
  /**
   *  指定联系人（须填写 openUserId ）
   */
  WXShareScene[(WXShareScene.WXSceneSpecifiedSession = 3)] =
    'WXSceneSpecifiedSession';
})(WXShareScene || (WXShareScene = {}));
export var WXShareType;
(function (WXShareType) {
  WXShareType[(WXShareType.WXShareTypeText = 0)] = 'WXShareTypeText';
  WXShareType[(WXShareType.WXShareTypeImage = 1)] = 'WXShareTypeImage';
  WXShareType[(WXShareType.WXShareTypeMusic = 2)] = 'WXShareTypeMusic';
  WXShareType[(WXShareType.WXShareTypeVideo = 3)] = 'WXShareTypeVideo';
  WXShareType[(WXShareType.WXShareTypeWeb = 4)] = 'WXShareTypeWeb';
  WXShareType[(WXShareType.WXShareTypeMiniProgram = 5)] =
    'WXShareTypeMiniProgram';
})(WXShareType || (WXShareType = {}));
export var WXMiniProgramType;
(function (WXMiniProgramType) {
  /**
   *  正式版
   */
  WXMiniProgramType[(WXMiniProgramType.WXMiniProgramTypeRelease = 0)] =
    'WXMiniProgramTypeRelease';
  /**
   *  开发版
   */
  WXMiniProgramType[(WXMiniProgramType.WXMiniProgramTypeTest = 1)] =
    'WXMiniProgramTypeTest';
  /**
   *  体验版
   */
  WXMiniProgramType[(WXMiniProgramType.WXMiniProgramTypePreview = 2)] =
    'WXMiniProgramTypePreview';
})(WXMiniProgramType || (WXMiniProgramType = {}));
export var WXErrCode;
(function (WXErrCode) {
  /** 成功 */
  WXErrCode[(WXErrCode.WXSuccess = 0)] = 'WXSuccess';
  /** 普通错误类型 */
  WXErrCode[(WXErrCode.WXErrCodeCommon = -1)] = 'WXErrCodeCommon';
  /** 用户点击取消并返回 */
  WXErrCode[(WXErrCode.WXErrCodeUserCancel = -2)] = 'WXErrCodeUserCancel';
  /** 发送失败 */
  WXErrCode[(WXErrCode.WXErrCodeSentFail = -3)] = 'WXErrCodeSentFail';
  /** 授权失败 */
  WXErrCode[(WXErrCode.WXErrCodeAuthDeny = -4)] = 'WXErrCodeAuthDeny';
  /** 微信不支持 */
  WXErrCode[(WXErrCode.WXErrCodeUnsupported = -5)] = 'WXErrCodeUnsupported';
})(WXErrCode || (WXErrCode = {}));
