import { NativeModules, Platform } from 'react-native';

const { BCWechat } = NativeModules;

import {
  WXShareReq,
  WXShareResp,
  WXErrCode,
  WXPayReq,
  WXPayResp,
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

export async function shareMessage(request: WXShareReq) {
  let result: WXShareResp = await BCWechat.shareData(request);
  if (result.errCode !== WXErrCode.WXSuccess) {
    throw Error(result.errStr ?? result.errCode.toString());
  }
  return result;
}

export async function pay(request: WXPayReq) {
  let result: WXPayResp = await BCWechat.pay(request);
  if (result.errCode !== WXErrCode.WXSuccess) {
    throw Error(result.errStr ?? result.errCode.toString());
  }
  return result;
}
