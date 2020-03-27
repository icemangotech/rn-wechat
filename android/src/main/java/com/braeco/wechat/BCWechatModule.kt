package com.braeco.wechat

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.tencent.mm.opensdk.constants.Build
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.WXAPIFactory

class BCWechatModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private val INVOKE_FAILED = "registerApp required."
  private val NOT_REGISTERED = "WeChat API invoke returns false."

  private var mAppId: String? = null
  private var mWXApi: IWXAPI? = null

  /**
   * @return the name of this module. This will be the name used to `require()` this module
   * from javascript.
   */
  override fun getName(): String {
    return "BCWechat"
  }

  override fun getConstants(): Map<String, Any> {
    val constants = hashMapOf<String, Any>()

    constants["TimelineSupported"] = Build.TIMELINE_SUPPORTED_SDK_INT

    return constants
  }

  @ReactMethod
  fun registerApp(appId: String, promise: Promise) {
    mAppId = appId
    mWXApi = WXAPIFactory.createWXAPI(this.reactApplicationContext.baseContext, appId, true)
    if (mWXApi?.registerApp(appId) == true) {
      promise.resolve(null)
    } else {
      promise.reject("", INVOKE_FAILED)
    }
  }

  @ReactMethod
  fun isWXAppInstalled(promise: Promise) {
    val api = mWXApi
    if (api != null) {
      promise.resolve(api.isWXAppInstalled)
    } else {
      promise.reject("", NOT_REGISTERED)
    }
  }

  @ReactMethod
  fun getApiVersion(promise: Promise) {
    promise.resolve(Build.SDK_VERSION_NAME)
  }

  @ReactMethod
  fun getWXAppSupportAPI(promise: Promise) {
    val api = mWXApi
    if (api != null) {
      promise.resolve(api.wxAppSupportAPI)
    } else {
      promise.reject("", NOT_REGISTERED)
    }
  }

  @ReactMethod
  fun openWXApp(promise: Promise) {
    val api = mWXApi
    if (api != null) {
      if (api.openWXApp()) {
        promise.resolve(null)
      } else {
        promise.reject("", INVOKE_FAILED)
      }
    } else {
      promise.reject("", NOT_REGISTERED)
    }
  }
}
