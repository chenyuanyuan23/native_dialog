import 'dart:async';
import 'package:flutter/services.dart';

final NativeDialog nativeDialog = NativeDialog();

class NativeDialog {
  final MethodChannel _channel = const MethodChannel('native_dialog');

  NativeDialog() {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  int _callbackIndex = 0;
  final Map _callbacks = {};

  // 弹框提示
  Future<void> alert({String? title, String? text}) {
    Completer<void> comp = Completer();
    int index = ++_callbackIndex;
    _callbacks[index] = (args) {
      comp.complete();
    };
    _channel.invokeMethod(
        'alertDialog', {"title": title, "text": text, "callback": index});
    return comp.future;
  }

  // 弹框提示
  Future<void> toast(String title) {
    Completer<void> comp = Completer();
    int index = ++_callbackIndex;
    _callbacks[index] = (args) {
      comp.complete();
    };
    return _channel
        .invokeMethod('toastDialog', {"title": title, "callback": index});
  }

  //load弹窗引导
  Future<void> showLoading(String version, String content,
      {String status = '0'}) {
    return _channel.invokeMethod('loadingDialog',
        {"version": version, "content": content, "status": status});
  }

  // 确认框
  Future<bool> confirm(
      {String? title, String? text, String? confirmText, String? cancleText}) {
    //弹窗如果没有成功,则要去掉回调
    Completer<bool> comp = Completer();
    int index = ++_callbackIndex;
    _callbacks[index] = (args) {
      //如果等于1则认为是成功的
      comp.complete(args == "1");
    };
    Map info = {
      "title": title,
      "text": text,
      "callback": index,
      "confirmText": confirmText ?? "确定",
      "cancleText": cancleText ?? "取消",
    };
    _channel.invokeMethod('confirmDialog', info);
    return comp.future;
  }

  void _doCallback(Map arguments) {
    int callback = arguments['callback'];
    dynamic args = arguments.containsKey('args') ? arguments['args'] : null;
    //是否包含这个回调
    if (_callbacks.containsKey(callback)) {
      //执行后删除
      _callbacks[callback](args);
      _callbacks.remove(callback);
    }
  }

  // 数字键盘验证码情况
  Future<String> carame() {
    Completer<String> comp = Completer();
    int index = ++_callbackIndex;
    _callbacks[index] = (args) {
      _callbacks.remove(index);
      comp.complete(args);
    };
    _channel.invokeMethod('createCarameDialog');
    return comp.future;
  }

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'doCallback':
        _doCallback(call.arguments);
        return;
    }
    throw MissingPluginException(
      '${call.method} was invoked but has no handler',
    );
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
