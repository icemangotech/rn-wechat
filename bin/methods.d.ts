import {
  WXShareReq,
  WXShareResp,
  WXPayReq,
  WXPayResp,
  WXLaunchMiniProgramReq,
  WXLaunchMiniProgramResp,
  WXBaseResp,
  WXSendAuthReq,
  WXSendAuthResp,
} from './types';
export declare function registerApp(
  appId: string,
  universalLink: string
): Promise<any>;
/**
 * @platform iOS
 */
export declare function getWXAppInstallUrl(): Promise<string>;
export declare function getApiVersion(): Promise<string>;
/**
 * @platform iOS
 */
export declare function isWXAppSupportApi(): Promise<boolean>;
/**
 * @platform Android
 */
export declare function getWXAppSupportAPI(): Promise<number>;
export declare function isWXAppInstalled(): Promise<boolean>;
export declare function openWXApp(): Promise<void>;
/**
 * promises will reject with this error when API call finish with an errCode other than zero.
 */
export declare class WechatError extends Error {
  code: number;
  constructor(resp: WXBaseResp);
}
export declare const shareMessage: (
  request: WXShareReq
) => Promise<WXShareResp>;
export declare const pay: (request: WXPayReq) => Promise<WXPayResp>;
export declare const launchMiniProgram: (
  request: WXLaunchMiniProgramReq
) => Promise<WXLaunchMiniProgramResp>;
export declare const sendAuthRequest: (
  request: WXSendAuthReq
) => Promise<WXSendAuthResp>;
