package com.guigug.server.NimPlugin.utils;

import android.graphics.Bitmap;
import android.os.Environment;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONException;
import com.alibaba.fastjson.JSONObject;
import com.guigug.server.NimPlugin.model.ImageMessage;
import com.guigug.server.NimPlugin.model.TextMessage;
import com.guigug.server.NimPlugin.model.VoiceMessage;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.msg.MessageBuilder;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.CustomMessageConfig;
import com.netease.nimlib.sdk.msg.model.IMMessage;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel.Result;

public class NimMessageUtils {
    static final String MSG_SEND_SUCCESS = "消息发送成功";
    static final String MSG_SEND_FAIL = "消息发送失败　";


    public static void handleResult(int status, Object desc, Result callback) {
        if (status == 0) {
            callback.success(desc);
        } else {
            callback.error(Integer.toString(status), desc.toString(), "");
        }
    }

    public static CustomMessageConfig toMessageSendingOptions(JSONObject json) throws JSONException {
        CustomMessageConfig messageSendingOptions = new CustomMessageConfig();

        if (json.containsKey("enableHistory") && !json.containsValue("enableHistory")) {
            messageSendingOptions.enableHistory = json.getBoolean("enableHistory");
        }

        if (json.containsKey("enableRoaming") && !json.containsValue("enableRoaming")) {
            messageSendingOptions.enableRoaming = json.getBoolean("enableRoaming");
        }

        if (json.containsKey("enableSelfSync") && !json.containsValue("enableSelfSync")) {
            messageSendingOptions.enableSelfSync = json.getBoolean("enableSelfSync");
        }

        if (json.containsKey("enablePush") && !json.containsValue("enablePush")) {
            messageSendingOptions.enablePush = json.getBoolean("enablePush");
        }

        if (json.containsKey("enablePushNick") && !json.containsValue("enablePushNick")) {
            messageSendingOptions.enablePushNick = json.getBoolean("enablePushNick");
        }
        if (json.containsKey("enableUnreadCount") && !json.containsValue("enableUnreadCount")) {
            messageSendingOptions.enableUnreadCount = json.getBoolean("enableUnreadCount");
        }
        if (json.containsKey("enableRoute") && !json.containsValue("enableRoute")) {
            messageSendingOptions.enableRoute = json.getBoolean("enableRoute");
        }
        if (json.containsKey("enablePersist") && !json.containsValue("enablePersist")) {
            messageSendingOptions.enablePersist = json.getBoolean("enablePersist");
        }

        return messageSendingOptions;
    }


    public static void sendMessage(String account, String type, int duration, String messageFlag, String msg, CustomMessageConfig options,
                                   final Result result) {
        // 默认为单聊类型
        SessionTypeEnum sessionType = SessionTypeEnum.P2P;
        // 创建一个消息
        IMMessage message = null;
        try {
            Log.e("TAG", "聊天账号" + account);
            if (type.equals("NIMMessageTypeText")) {
                TextMessage textMessage = new TextMessage();
                textMessage.text = msg;
                textMessage.type = type;
                message = MessageBuilder.createTextMessage(account, sessionType, textMessage.text);
            } else if (type.equals("NIMMessageTypeImage")) {
                ImageMessage imageMessage = new ImageMessage();
                imageMessage.path = msg;
                imageMessage.type = type;
                File file = new File(imageMessage.path);
                message = MessageBuilder.createImageMessage(account, sessionType, file, file.getName());
            } else if (type.equals("NIMMessageTypeAudio")) {
                VoiceMessage voiceMessage = new VoiceMessage();
                voiceMessage.path = msg;
                voiceMessage.type = type;
                File file = new File(voiceMessage.path);
                message = MessageBuilder.createAudioMessage(account, sessionType, file, duration);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        Map map = new HashMap();
        map.put("messageFlag", messageFlag);
        message.setLocalExtension(map);
        if (options != null) {
            message.setConfig(options);
        }
        final IMMessage messageTmp = message;
        // 发送给对方
        NIMClient.getService(MsgService.class).sendMessage(message, false).setCallback(new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                result.success(JSON.toJSON(messageTmp));
            }

            @Override
            public void onFailed(int i) {
                handleResult(i, MSG_SEND_FAIL, result);
            }

            @Override
            public void onException(Throwable throwable) {
                throwable.printStackTrace();
                handleResult(-2, throwable.getMessage(), result);
            }
        });
    }

    static String storeImage(Bitmap bitmap, String filename, String pkgName) {
        File avatarFile = new File(getAvatarPath(pkgName));
        if (!avatarFile.exists()) {
            avatarFile.mkdirs();
        }

        String filePath = getAvatarPath(pkgName) + filename + ".png";
        try {
            FileOutputStream fos = new FileOutputStream(filePath);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos);
            bos.flush();
            bos.close();
            return filePath;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return "";
        } catch (IOException e) {
            e.printStackTrace();
            return "";
        }
    }

    static String getFilePath(String pkgName) {
        return Environment.getExternalStorageDirectory() + "/" + pkgName;
    }

    static String getAvatarPath(String pkgName) {
        return getFilePath(pkgName) + "/images/avatar/";
    }


    /**
     * 根据绝对路径或 URI 获得本地图片。
     *
     * @param path 文件路径或者 URI。
     * @return 文件对象。
     */
    static File getFile(String path) throws FileNotFoundException {
        File file = new File(path); // if it is a absolute path

        if (!file.isFile()) {
            URI uri = URI.create(path); // if it is a uri.
            file = new File(uri);
        }

        if (!file.exists() || !file.isFile()) {
            throw new FileNotFoundException();
        }

        return file;
    }

}
