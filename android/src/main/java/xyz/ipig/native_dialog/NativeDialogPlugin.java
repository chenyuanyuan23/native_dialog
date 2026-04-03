package xyz.ipig.native_dialog;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
//import io.flutter.plugin.common.PluginRegistry.Registrar;

import xyz.ipig.native_dialog.OnAdClickListener;
import xyz.ipig.native_dialog.PromptButton;
import xyz.ipig.native_dialog.PromptButtonListener;
import xyz.ipig.native_dialog.PromptDialog;

// import com.xiaokun.dialogtiplib.dialog_tip.TipLoadDialog;

// import com.androidufo.loading.UFOLoadingController;
// import com.androidufo.loading.UFOLoadingDialog;

import java.util.HashMap;
import android.app.Activity;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/** NativeDialogPlugin */
public class NativeDialogPlugin implements FlutterPlugin,  ActivityAware, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static Activity _activity;
  // private TipLoadDialog tipLoadDialog;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "native_dialog");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
//  public static void registerWith(Registrar registrar) {
//    final MethodChannel channel = new MethodChannel(registrar.messenger(), "native_dialog");
//    channel.setMethodCallHandler(new NativeDialogPlugin());
//  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    _activity = activityPluginBinding.getActivity();
  }

    @Override
  public void onDetachedFromActivityForConfigChanges() {
    // Log.i(TAG, "onDetachedFromActivityForConfigChanges");

  }

    @Override
  public void onDetachedFromActivity() {
    // Log.i(TAG, "onDetachedFromActivity");
  }

    @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    // Log.i(TAG, "onReattachedToActivityForConfigChanges");
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String method = call.method;
    HashMap<String, Object> args = (HashMap<String, Object>)call.arguments;
    if (method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    else if(method.equals("loadingDialog")) {
      String version = args.get("version").toString();
      String content = args.get("content").toString();
      String status = args.get("status").toString();
      loadDialog(version,content,status);
      
      result.success("loadDialog success");
    }
    else {
      result.notImplemented();
    }
  }

  private PromptDialog promptDialog;
  private void loadDialog(String version,String content,String status){
    if(promptDialog == null){
      promptDialog = new PromptDialog(_activity);
    }
    if("1".equals(status)){
      promptDialog.dismissImmediately();
      
    }else{
      promptDialog.showLoading("" + version + "-" + content,false);
    }
  }


//   private void showUFODialog() {
//         UFOLoadingDialog dialog = createController(
//                 "我是Dialog，正在加载...",
//                 Color.WHITE,
//                 Color.RED,
//                 Color.RED,
//                 UFOLoadingController.IndicatorStyle.SPIN_LINE,
//                 false
//         ).createDialog(_activity);
//         dialog.setCancelable(false);
//         dialog.show();
// //        dialog.setDimVal(UFODialog.DimVal.NONE);
//     }

//     private UFOLoadingController createController(String msg,
//                                                   int bgColor,
//                                                   int msgColor,
//                                                   int indicatorColor,
//                                                   UFOLoadingController.IndicatorStyle style,
//                                                   boolean horizontal) {
//         return new UFOLoadingController.Builder()
//                 .bgColor(bgColor)
//                 .bgRadius(DisplayUtils.dp2px(this, 3))
//                 .padding(DisplayUtils.dp2px(this, 6))
//                 .horizontalMode(horizontal)
//                 .intervalMargin(10)
//                 .msg(msg)
//                 .msgTextColor(msgColor)
//                 .msgTextSize(14)
//                 .indicatorColor(indicatorColor)
//                 .indicatorStyle(style)
// //                .indicatorSize(DisplayUtils.dp2px(this, 20))
//                 .indicatorNormalRotate()
//                 .build();
//     }




  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
