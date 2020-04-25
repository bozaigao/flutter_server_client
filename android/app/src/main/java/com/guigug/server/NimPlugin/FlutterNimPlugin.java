package com.guigug.server.NimPlugin;

import android.content.Context;
import android.util.Log;
import androidx.annotation.NonNull;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONException;
import com.alibaba.fastjson.JSONObject;
import com.guigug.server.NimPlugin.utils.NimMessageUtils;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthService;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.msg.MessageBuilder;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.CustomMessageConfig;
import com.netease.nimlib.sdk.msg.model.IMMessage;
import com.netease.nimlib.sdk.msg.model.QueryDirectionEnum;
import com.netease.nimlib.sdk.msg.model.RecentContact;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.UserInfo;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterNimPlugin
 */
public class FlutterNimPlugin implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "www.guigug.com/flutter_nim_plugin";
    static MethodChannel channel;
    static final int SUCCEED_CODE = 0;
    static final int ERR_CODE_PARAMETER = 1;
    static final int ERR_CODE = -1;
    static final String ERR_MSG_PARAMETER = "参数错误";
    static final String LOGIN_FAIL = "登录失败";
    static final String LOGIN_SUCCESS = "登录成功";
    public static Context context;
    private IMMessage message;


    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(FlutterEngine flutterEngine, Context context) {
        FlutterNimPlugin.context = context;
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        FlutterNimPlugin instance = new FlutterNimPlugin();
        //setMethodCallHandler在此通道上接收方法调用的回调
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("sendMessage")) {
            sendMessage(call, result);
        } else if (call.method.equals("nimLogin")) {
            nimLogin(call, result);
        } else if (call.method.equals("getAllSessions")) {
            getAllSessions(call, result);
        } else if (call.method.equals("loginOut")) {
            loginOut(call, result);
        } else if (call.method.equals("fetchMessageHistory")) {
            fetchMessageHistory(call, result);
        } else if (call.method.equals("getUsersInfo")) {
            getUsersInfo(call, result);
        } else if (call.method.equals("markAllMessagesReadInSession")) {
            markAllMessagesReadInSession(call, result);
        } else if (call.method.equals("markAllMessagesRead")) {
            markAllMessagesRead(call, result);
        } else if (call.method.equals("resetMessage")) {
            resetMessage(call, result);
        } else {
            result.notImplemented();
        }
    }

    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-02-08
     * @function: 登录网易云信
     */
    private void nimLogin(MethodCall call, final Result result) {
        String account = "";
        String token = "";
        String appKey = "";
        HashMap<String, Object> map = call.arguments();

        JSONObject params = new JSONObject(map);
        if (params.containsKey("account")) {
            account = params.getString("account");
        }
        if (params.containsKey("token")) {
            token = params.getString("token");
        }
        if (params.containsKey("appKey")) {
            appKey = params.getString("appKey");
        }
        Log.e("TAG", "开始登录" + "  account:" + account + "  token:" + token + "  appKey:" + appKey);
        LoginInfo info = new LoginInfo(account, token, appKey);
        //登录回调
        NIMClient.getService(AuthService.class).login(info).setCallback(new RequestCallback<LoginInfo>() {
            @Override
            public void onSuccess(LoginInfo loginInfo) {
                Log.e("TAG", "登录成功");
                NimMessageUtils.handleResult(SUCCEED_CODE, LOGIN_SUCCESS, result);
            }

            @Override
            public void onFailed(int i) {
                Log.e("TAG", "登录失败" + i);
                NimMessageUtils.handleResult(i, LOGIN_FAIL, result);
            }

            @Override
            public void onException(Throwable throwable) {
                throwable.printStackTrace();
                Log.e("TAG", "登录失败");
                NimMessageUtils.handleResult(ERR_CODE, throwable.getMessage(), result);
            }
            // 可以在此保存LoginInfo到本地，下次启动APP做自动登录用
        });
        //消息首发检测
        Observer<List<IMMessage>> incomingMessageObserver =
                new Observer<List<IMMessage>>() {
                    @Override
                    public void onEvent(List<IMMessage> messages) {
                        // 处理新收到的消息，为了上传处理方便，SDK 保证参数 messages 全部来自同一个聊天对象。
                        Log.e("TAG", "接收到消息了");
                        FlutterNimPlugin.channel.invokeMethod("onReceiveMessage", JSON.toJSON(messages));
                        FlutterNimPlugin.channel.invokeMethod("onSessionUpdate", JSON.toJSON(messages));
                    }
                };
        NIMClient.getService(MsgServiceObserve.class)
                .observeReceiveMessage(incomingMessageObserver, true);
        //检测被踢
        NIMClient.getService(AuthServiceObserver.class).observeOnlineStatus(
                new Observer<StatusCode>() {
                    public void onEvent(StatusCode status) {
                        if (status.wontAutoLogin()) {
                            Log.e("TAG", "被踢了");
                            FlutterNimPlugin.channel.invokeMethod("onKick", null);
                            // 被踢出、账号被禁用、密码错误等情况，自动登录失败，需要返回到登录界面进行重新登录操作
                        }
                    }
                }, true);
    }

    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-04-19
     * @function: 获取最近所有会话
     */
    private void getAllSessions(MethodCall call, final Result result) {
        NIMClient.getService(MsgService.class).queryRecentContacts()
                .setCallback(new RequestCallbackWrapper<List<RecentContact>>() {
                    @Override
                    public void onResult(int code, List<RecentContact> recents, Throwable e) {
                        // recents参数即为最近联系人列表（最近会话列表）
                        Log.e("TAG", "获取最近所有会话"+recents.size());
                        result.success(JSON.toJSON(recents));
                        if (e != null) {
                            e.printStackTrace();
                        }
                    }
                });
    }


    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-04-21
     * @function: 获取所有的会话用户资料
     */
    private void getUsersInfo(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        JSONObject params = new JSONObject(map);
        List userIds = params.getJSONArray("userIds");
        if (userIds.size() == 0) {
            result.success(JSON.toJSON(new ArrayList<>()));
        }
        NIMClient.getService(UserService.class).fetchUserInfo(userIds)
                .setCallback(new RequestCallback<List<UserInfo>>() {

                    @Override
                    public void onSuccess(List<UserInfo> param) {
                        Log.e("TAG", "获取用户资料" + param.size());
                        result.success(JSON.toJSON(param));
                    }

                    @Override
                    public void onFailed(int code) {
                        Log.e("TAG", "获取用户资料" + code);
                        result.success(JSON.toJSON(new ArrayList<>()));
                    }

                    @Override
                    public void onException(Throwable exception) {
                        exception.printStackTrace();
                        result.success(JSON.toJSON(new ArrayList<>()));
                    }
                });
    }


    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-04-22
     * @function: 设置全部会话已读
     */
    private void markAllMessagesRead(MethodCall call, final Result result) {
        NIMClient.getService(MsgService.class).clearAllUnreadCount();
    }

    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-04-22
     * @function: 设置某一个会话已读
     */
    private void markAllMessagesReadInSession(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        JSONObject params = new JSONObject(map);
        NIMClient.getService(MsgService.class).clearUnreadCount(params.getString("sessionId"), SessionTypeEnum.P2P);
    }

    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-02-08
     * @function: 重置message
     */
    private void resetMessage(MethodCall call, final Result result) {
        message = null;
    }


    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-02-08
     * @function: 登出
     */
    private void loginOut(MethodCall call, final Result result) {
        NIMClient.getService(AuthService.class).logout();
        result.success(null);
    }


    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-02-07
     * @function: 发送文本、图片、音频消息
     */
    private void sendMessage(MethodCall call, Result result) {
        String account = "";
        String type = "";
        String messageFlag = "";
        int duration = 0;
        HashMap<String, Object> map = call.arguments();
        CustomMessageConfig messageSendingOptions = null;
        try {
            JSONObject params = new JSONObject(map);
            if (params.containsKey("duration")) {
                duration = params.getInteger("duration");
            }
            if (params.containsKey("account")) {
                account = params.getString("account");
            }
            if (params.containsKey("type")) {
                type = params.getString("type");
            }
            if (params.containsKey("messageFlag")) {
                messageFlag = params.getString("messageFlag");
            }
            if (params.containsKey("messageSendingOptions")) {
                messageSendingOptions = NimMessageUtils.toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }
            String content = "";
            if (type.equals("NIMMessageTypeText")) {
                content = params.getString("message");
            } else {
                content = params.getString("path");
            }
            NimMessageUtils.sendMessage(account, type,duration, messageFlag, content, messageSendingOptions, result);
        } catch (JSONException e) {
            e.printStackTrace();
            NimMessageUtils.handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }
    }


    /**
     * @author 何晏波
     * @QQ 1054539528
     * @date 2020-02-08
     * @function: 获取历史消息
     */
    private void fetchMessageHistory(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        JSONObject params = new JSONObject(map);
        int limit = 30;
        limit = params.getIntValue("limit");
        // 服务端拉取历史消息
        long newTime = System.currentTimeMillis();
        IMMessage anchor = null;
        if (message != null) {
            anchor = message;
        } else {
            anchor = MessageBuilder.createEmptyMessage(params.getString("sessionId"), SessionTypeEnum.P2P, newTime);
        }
        NIMClient.getService(MsgService.class).pullMessageHistoryEx(anchor, 0, limit, QueryDirectionEnum.QUERY_OLD, false).setCallback(new RequestCallback<List<IMMessage>>() {
            @Override
            public void onSuccess(List<IMMessage> messages) {
                if (messages.size() > 0) {
                    message = messages.get(messages.size() - 1);
                }
                result.success(JSON.toJSON(messages));
            }

            @Override
            public void onFailed(int code) {
                result.success(JSON.toJSON(new ArrayList()));
                Log.e("TAG", "报错了");
            }

            @Override
            public void onException(Throwable exception) {
                result.success(JSON.toJSON(new ArrayList()));
                Log.e("TAG", "报错了2");
                exception.printStackTrace();
            }
        });
    }


}
