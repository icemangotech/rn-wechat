import { NativeModules } from 'react-native';

const { BCWechat } = NativeModules;

import {
  WXShareReq,
  WXShareResp,
  WXErrCode,
  WXPayReq,
  WXPayResp,
} from './types';

export async function registerApp(appId: string, universalLink: string) {
  return BCWechat.registerApp(appId, universalLink);
}

export function getWXAppInstallUrl(): Promise<string> {
  return BCWechat.getWXAppInstallUrl();
}

export function getApiVersion(): Promise<string> {
  return BCWechat.getApiVersion();
}

export function isWXAppSupportApi(): Promise<boolean> {
  return BCWechat.isWXAppSupportApi();
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
