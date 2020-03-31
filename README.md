# rn-wechat

[![NPM Version](https://img.shields.io/npm/v/@phecdas/rn-wechat)](https://www.npmjs.com/package/@phecdas/rn-wechat) [![LICENSE](https://img.shields.io/github/license/icemangotech/rn-wechat)](https://github.com/icemangotech/rn-wechat/blob/master/LICENSE)

[WechatSDK](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Resource_Center_Homepage.html) 的 react-native 库，基于 [react-native-wechat](https://github.com/yorkie/react-native-wechat) 完成。需要 react-native 版本 0.60 及以上。

## 概要

|                    |   iOS   | Android |
| :----------------: | :-----: | :-----: |
|      Version       | 1.8.6.2 |  5.5.8  |
|       Share        |   ✅    |   ✅    |
|        Pay         |   ✅    |   ✅    |
|        Auth        |   ✅    |   ✅    |
| Launch MiniProgram |   ✅    |   ✅    |

## 安装

``` bash
yarn add @phecdas/rn-wechat
# or
npm install @phecdas/rn-wechat
```

### iOS

1. `cd ios; pod install`;
2. 参考 [微信开放文档](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/iOS.html) ，配置 **Universal links**、**URL type**、**LSApplicationQueriesSchemes**
3. 配置你的 `AppDelegate.m` ，使其能正确处理 URL

``` objective-c
// ios 9.0+
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
  return [RCTLinkingManager application:application openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
  return [RCTLinkingManager application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}
```

### Android

1. 向 `android/app/proguard.pro` 添加规则：

```properties
-keep class com.tencent.mm.opensdk.** {
    *;
}

-keep class com.tencent.wxop.** {
    *;
}

-keep class com.tencent.mm.sdk.** {
    *;
}
```

2. 参考 [微信开放文档](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/Android.html) 新建 `android/app/src/main/java/YOUR/PACKAGE/wxapi/WXEntryActivity.java` 如下

``` java
// WXEntryActivity.java
package YOUR.PACKAGE.wxapi;

import android.app.Activity;
import android.os.Bundle;

import com.braeco.wechat.BCWechatModule;

public class WXEntryActivity extends Activity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    BCWechatModule.handleIntent(getIntent());
    finish();
  }
}
```

添加如下代码到 `ApplicationManifest.xml`

``` xml
<activity
    android:name=".wxapi.WXEntryActivity"
    android:label="@string/app_name"
    android:theme="@android:style/Theme.Translucent.NoTitleBar"
    android:exported="true"
    android:taskAffinity="填写你的包名"
    android:launchMode="singleTask">
</activity>
```

3. 支付功能，参考文档新建 `android/app/src/main/java/YOUR/PACKAGE/wxapi/WXPayEntryActivity.java` 如下

``` java
// WXPayEntryActivity.java
package YOUR.PACKAGE.wxapi;

import android.app.Activity;
import android.os.Bundle;
import com.braeco.wechat.BCWechatModule;

public class WXPayEntryActivity extends Activity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    BCWechatModule.handleIntent(getIntent());
    finish();
  }
}
```

添加如下代码到 `ApplicationManifest.xml`

``` xml
<activity
    android:name=".wxapi.WXPayEntryActivity"
    android:label="@string/app_name"
    android:theme="@android:style/Theme.Translucent.NoTitleBar"
    android:exported="true"
    android:taskAffinity="填写你的包名"
    android:launchMode="singleTask">
</activity>
```

## 使用

必须先向微信注册你的 App

``` typescript
// App.tsx or App.jsx
import Wechat from '@phecdas/rn-wechat'

Wechat.registerApp(App_Id, Universal_Link);
```

### 分享

``` typescript
import WeChat, { WXShareType, WXShareScene } from '@phecdas/rn-wechat';

try {
  await WeChat.shareMessage({
    type: WXShareType.WXShareTypeText,
    text: '要分享的文字',
    scene: WXShareScene.WXSceneSession,
  });
  // 注意微信为了保护用户隐私，即使用户取消，也会返回成功
} catch (error) {
  // 所以失败是有其他原因的
}
```

目前小程序仅支持分享到对话。

其他用法参考 Typescript 声明文件。

## License

BSD-3-Clause
