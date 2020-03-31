import { NativeModules, Platform } from 'react-native';
const { BCWechat } = NativeModules;
import { WXErrCode } from './types';
export async function registerApp(appId, universalLink) {
  if (Platform.OS === 'ios') {
    return BCWechat.registerApp(appId, universalLink);
  } else {
    return BCWechat.registerApp(appId);
  }
}
/**
 * @platform iOS
 */
export function getWXAppInstallUrl() {
  return BCWechat.getWXAppInstallUrl();
}
export function getApiVersion() {
  return BCWechat.getApiVersion();
}
/**
 * @platform iOS
 */
export function isWXAppSupportApi() {
  return BCWechat.isWXAppSupportApi();
}
/**
 * @platform Android
 */
export function getWXAppSupportAPI() {
  return BCWechat.getWXAppSupportAPI();
}
export function isWXAppInstalled() {
  return BCWechat.isWXAppInstalled();
}
export function openWXApp() {
  return BCWechat.openWXApp();
}
function generateFunction(nativeMethodName) {
  return async function (request) {
    const nativeMethod = BCWechat[nativeMethodName];
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
  constructor(resp) {
    const message = resp.errStr || resp.errCode.toString();
    super(message);
    this.name = 'WechatError';
    this.code = resp.errCode;
    Object.setPrototypeOf(this, WechatError.prototype);
  }
}
export const shareMessage = generateFunction('shareData');
export const pay = generateFunction('pay');
export const launchMiniProgram = generateFunction('launchMiniProgram');
export const sendAuthRequest = generateFunction('sendAuthRequest');
