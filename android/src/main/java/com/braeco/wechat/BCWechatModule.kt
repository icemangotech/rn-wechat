package com.braeco.wechat

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import com.facebook.common.executors.UiThreadImmediateExecutorService
import com.facebook.common.references.CloseableReference
import com.facebook.common.util.UriUtil
import com.facebook.datasource.DataSource
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.imagepipeline.common.ResizeOptions
import com.facebook.imagepipeline.datasource.BaseBitmapDataSubscriber
import com.facebook.imagepipeline.image.CloseableImage
import com.facebook.imagepipeline.request.ImageRequestBuilder
import com.facebook.react.bridge.*
import com.tencent.mm.opensdk.constants.Build
import com.tencent.mm.opensdk.constants.ConstantsAPI
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram
import com.tencent.mm.opensdk.modelmsg.*
import com.tencent.mm.opensdk.modelpay.PayReq
import com.tencent.mm.opensdk.modelpay.PayResp
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import java.lang.Exception
import java.util.*
import kotlin.collections.ArrayList

class BCWechatModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), IWXAPIEventHandler {
  private val INVOKE_FAILED = "registerApp required."
  private val NOT_REGISTERED = "WeChat API invoke returns false."
  private val INVALID_ARGUMENT = "invalid argument."

  private var mAppId: String? = null
  private var mWXApi: IWXAPI? = null
  private var mSendMessagePromise: Promise? = null
  private var mPayPromise: Promise? = null
  private var mLaunchMini: Promise? = null
  private var mAuthPromise: Promise? = null

  companion object {
    @JvmStatic
    private val modules = ArrayList<BCWechatModule>()

    @JvmStatic
    fun handleIntent(intent: Intent) {
      for (mod in modules) {
        mod.mWXApi?.handleIntent(intent, mod)
      }
    }
  }

  override fun initialize() {
    super.initialize()
    modules.add(this)
  }

  override fun onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy()
    if (mWXApi != null) {
      mWXApi = null
    }
    modules.remove(this)
  }

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

  @ReactMethod
  fun shareData(data: ReadableMap, promise: Promise) {
    if (mWXApi == null) {
      promise.reject("", NOT_REGISTERED)
      return
    }
    val thumbUrl = if (data.hasKey("thumbUrl")) extractString(data, "thumbUrl") else ""
    if (thumbUrl?.isNotEmpty() == true) {
      loadImage(thumbUrl, true) {
        shareData(data, it, promise)
      }
    } else {
      shareData(data, null, promise)
    }
  }

  @ReactMethod
  fun pay(data: ReadableMap, promise: Promise) {
    val payReq = PayReq()
    payReq.appId = mAppId

    payReq.partnerId = extractString(data, "partnerId")
    payReq.prepayId = extractString(data, "prepayId")
    payReq.nonceStr = extractString(data, "nonceStr")
    payReq.timeStamp = extractString(data, "timeStamp")
    payReq.packageValue = extractString(data, "package")
    payReq.sign = extractString(data, "sign")
    payReq.extData = extractString(data, "extData")


    val errMsg = sendRequest(payReq)
    if (errMsg == null) {
      mPayPromise = promise
    } else {
      promise.reject("", errMsg)
    }
  }

  @ReactMethod
  fun launchMiniProgram(data: ReadableMap, promise: Promise) {
    val req = WXLaunchMiniProgram.Req()

    req.userName = extractString(data, "userName")
    req.path = extractString(data, "path")
    req.miniprogramType = data.getInt("miniProgramType")

    val errMsg = sendRequest(req)
    if (errMsg == null) {
      mLaunchMini = promise
    } else {
      promise.reject("", errMsg)
    }
  }

  @ReactMethod
  fun sendAuthRequest(data: ReadableMap, promise: Promise) {
    val req = SendAuth.Req()

    req.scope = extractString(data, "scope")
    req.state = extractString(data, "state")

    val errMsg = sendRequest(req)
    if (errMsg == null) {
      mAuthPromise = promise
    } else {
      promise.reject("", errMsg)
    }
  }

  private fun sendRequest(req: BaseReq): String? {
    val api = mWXApi
    return if (!req.checkArgs()) {
      INVALID_ARGUMENT
    } else if (api == null) {
      NOT_REGISTERED
    } else {
      val success = api.sendReq(req)
      if (success) null else INVOKE_FAILED
    }
  }

  private fun shareData(data: ReadableMap, thumb: Bitmap?, promise: Promise) {
    val type = WXShareType.fromInt(data.getInt("type"))

    var mediaObject: WXMediaMessage.IMediaObject? = null

    when (type) {
      WXShareType.WXShareTypeText -> {
        val text = extractString(data, "text")
        mediaObject = if (text == null) null else {
          val ret = WXTextObject()
          ret.text = text
          ret
        }
      }
      WXShareType.WXShareTypeImage -> {
        val imageUrl = extractString(data, "imageUrl")
        loadImage(imageUrl, false) {
          val imageObject = WXImageObject(it)
          shareData(data, thumb, imageObject, promise)
        }
        return
      }
      WXShareType.WXShareTypeWeb -> {
        val webpageUrl = extractString(data, "webpageUrl")
        mediaObject = if (webpageUrl == null) null else {
          val obj = WXWebpageObject()
          obj.webpageUrl = webpageUrl
          obj
        }
      }
      WXShareType.WXShareTypeMusic -> {
        val musicUrl = extractString(data, "musicUrl")
        mediaObject = if (musicUrl == null) null else {
          val obj = WXMusicObject()
          obj.musicUrl = musicUrl
          obj.musicLowBandUrl = extractString(data, "musicLowBandUrl")
          obj.musicDataUrl = extractString(data, "musicDataUrl")
          obj.musicLowBandDataUrl = extractString(data, "musicLowBandDataUrl")
          obj
        }
      }
      WXShareType.WXShareTypeVideo -> {
        val videoUrl = extractString(data, "videoUrl")
        mediaObject = if (videoUrl == null) null else {
          val obj = WXVideoObject()
          obj.videoUrl = videoUrl
          obj.videoLowBandUrl = extractString(data, "videoLowBandUrl")
          obj
        }
      }
      WXShareType.WXShareTypeMiniProgram -> {
        val obj = WXMiniProgramObject()
        obj.webpageUrl = extractString(data, "webpageUrl")
        // NOTE: 注意此处键名大小写
        obj.miniprogramType = data.getInt("miniProgramType")
        obj.path = extractString(data, "path")
        obj.userName = extractString(data, "userName")
        obj.withShareTicket = data.getBoolean("withShareTicket")

        mediaObject = obj
      }
    }

    shareData(data, thumb, mediaObject, promise)
  }

  private fun shareData(data: ReadableMap, thumb: Bitmap?, mediaObject: WXMediaMessage.IMediaObject?, promise: Promise) {
    val message = WXMediaMessage()

    message.mediaObject = mediaObject
    if (thumb != null) message.setThumbImage(thumb)

    message.title = extractString(data, "title")
    message.description = extractString(data, "description")

    val req = SendMessageToWX.Req()
    req.message = message
    req.scene = data.getInt("scene")
    req.transaction = UUID.randomUUID().toString()

    val errMsg = sendRequest(req)
    if (errMsg == null) {
      mSendMessagePromise = promise
    } else {
      promise.reject("", errMsg)
    }
  }

  private fun loadImage(url: String?, shouldDownSample: Boolean, completionCallback: (Bitmap?) -> Unit) {
    var imageUri: Uri?
    try {
      imageUri = Uri.parse(url)

      if (imageUri.scheme == null) {
        imageUri = getResourceDrawableUri(reactApplicationContext, url)
      }
    } catch (e: Exception) {
        imageUri = null
    }

    if (imageUri != null) {
      val resizeOptions = if (shouldDownSample) ResizeOptions(100, 100) else null
      getImage(imageUri, resizeOptions) {
        completionCallback(it)
      }
    } else {
      completionCallback(null)
    }
  }

  private fun getImage(uri: Uri, resizeOptions: ResizeOptions?, completionCallback: (Bitmap?) -> Unit) {
    val dataSubscriber = object : BaseBitmapDataSubscriber() {
      override fun onFailureImpl(dataSource: DataSource<CloseableReference<CloseableImage>>?) {
        completionCallback(null)
      }

      /**
       * The bitmap provided to this method is only guaranteed to be around for the lifespan of the
       * method.
       *
       *
       * The framework will free the bitmap's memory after this method has completed.
       * @param bitmap
       */
      override fun onNewResultImpl(bitmap: Bitmap?) {
        if (bitmap != null) {
          if (bitmap.config != null) {
            completionCallback(bitmap.copy(bitmap.config, true))
          } else {
            completionCallback(bitmap.copy(Bitmap.Config.ARGB_8888, true))
          }
        } else {
          completionCallback(null)
        }
      }

    }

    val imageRequestBuilder = ImageRequestBuilder.newBuilderWithSource(uri)
    if (resizeOptions != null) {
      imageRequestBuilder.resizeOptions = resizeOptions
    }

    val imageRequest = imageRequestBuilder.build()
    val imagePipeline = Fresco.getImagePipeline()
    val dataSource = imagePipeline.fetchDecodedImage(imageRequest, null)
    dataSource.subscribe(dataSubscriber, UiThreadImmediateExecutorService.getInstance())

  }

  private fun getResourceDrawableUri(context: Context, name: String?): Uri? {
    if (name == null || name.isEmpty()) {
      return null
    }
    val imageName = name.toLowerCase().replace("-", "_")
    val resId = context.resources.getIdentifier(imageName, "drawable", context.packageName)

    return if (resId == 0) null else {
      Uri.Builder().scheme(UriUtil.LOCAL_RESOURCE_SCHEME).path(resId.toString()).build()
    }
  }

  private fun extractString(data: ReadableMap, key: String): String? {
    return if (data.hasKey(key)) data.getString(key) else null
  }

  override fun onResp(baseResp: BaseResp) {
    val map: WritableMap = Arguments.createMap()
    map.putInt("errCode", baseResp.errCode)
    map.putString("errStr", baseResp.errStr)
    map.putString("openId", baseResp.openId)
    map.putString("transaction", baseResp.transaction)

    when(baseResp.type) {
      ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX -> {
        mSendMessagePromise?.resolve(map)
      }
      ConstantsAPI.COMMAND_PAY_BY_WX -> {
        val payResp = baseResp as PayResp
        map.putString("returnKey", payResp.returnKey)
        map.putString("prepayId", payResp.prepayId)
        map.putString("extData", payResp.extData)
        mPayPromise?.resolve(map)
      }
      ConstantsAPI.COMMAND_LAUNCH_WX_MINIPROGRAM -> {
        val launchResp = baseResp as WXLaunchMiniProgram.Resp
        map.putString("extMsg", launchResp.extMsg)
        mLaunchMini?.resolve(map)
      }
      ConstantsAPI.COMMAND_SENDAUTH -> {
        val sendAuthResp = baseResp as SendAuth.Resp
        map.putString("code", sendAuthResp.code)
        map.putString("country", sendAuthResp.country)
        map.putString("lang", sendAuthResp.lang)
        map.putString("state", sendAuthResp.state)
        map.putString("url", sendAuthResp.url)
        map.putBoolean("authResult", sendAuthResp.authResult)
      }
      else -> {
        TODO("check type")
      }
    }
  }

  override fun onReq(p0: BaseReq?) {
    TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }
}
