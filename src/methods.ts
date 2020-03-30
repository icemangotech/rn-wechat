import { NativeModules, Platform } from 'react-native';

const { BCWechat } = NativeModules;

import {
  WXShareReq,
  WXShareResp,
  WXErrCode,
  WXPayReq,
  WXPayResp,
  WXLaunchMiniProgramReq,
  WXLaunchMiniProgramResp,
  WXBaseResp,
} from './types';

export async function registerApp(appId: string, universalLink: string) {
  if (Platform.OS === 'ios') {
    return BCWechat.registerApp(appId, universalLink);
  } else {
    return BCWechat.registerApp(appId);
  }
}

/**
 * @platform iOS
 */
export function getWXAppInstallUrl(): Promise<string> {
  return BCWechat.getWXAppInstallUrl();
}

export function getApiVersion(): Promise<string> {
  return BCWechat.getApiVersion();
}

/**
 * @platform iOS
 */
export function isWXAppSupportApi(): Promise<boolean> {
  return BCWechat.isWXAppSupportApi();
}

/**
 * @platform Android
 */
export function getWXAppSupportAPI(): Promise<number> {
  return BCWechat.getWXAppSupportAPI();
}

export function isWXAppInstalled(): Promise<boolean> {
  return BCWechat.isWXAppInstalled();
}

export function openWXApp(): Promise<void> {
  return BCWechat.openWXApp();
}

function generateFunction<Req, Resp extends WXBaseResp>(
  nativeMethodName: string
) {
  return async function (request: Req) {
    const nativeMethod: undefined | ((r: Req) => Promise<Resp>) =
      BCWechat[nativeMethodName];
    if (nativeMethod) {
      let result = await nativeMethod(request);
      if (result.errCode !== WXErrCode.WXSuccess) {
        throw new WechatError(result);
      }
      return result;
    } else {
      throw Error(`Native Method ${nativeMethodName} not found`);
    }
  };
}

/**
 * promises will reject with this error when API call finish with an errCode other than zero.
 */
export class WechatError extends Error {
  code: number;
  constructor(resp: WXBaseResp) {
    const message = resp.errStr || resp.errCode.toString();
    super(message);
    this.name = 'WechatError';
    this.code = resp.errCode;

    Object.setPrototypeOf(this, WechatError.prototype);
  }
}

export const shareMessage = generateFunction<WXShareReq, WXShareResp>(
  'shareData'
);

export const pay = generateFunction<WXPayReq, WXPayResp>('pay');

export const launchMiniProgram = generateFunction<
  WXLaunchMiniProgramReq,
  WXLaunchMiniProgramResp
>('launchMiniProgram');
