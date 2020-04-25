package com.guigug.server.NimPlugin.custom_model;

import com.alibaba.fastjson.JSONObject;

/**
 * @filename DefaultCustomAttachment.java
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-04-21 
 * @Description:
*/
public class DefaultCustomAttachment extends CustomAttachment {

    private String content;

    public DefaultCustomAttachment() {
        super(0);
    }

    @Override
    protected void parseData(String data) {
        content = data;
    }

    @Override
    protected JSONObject packData() {
        JSONObject data = null;
        try {
            data = JSONObject.parseObject(content);
        } catch (Exception e) {

        }
        return data;
    }

    public String getContent() {
        return content;
    }
}
