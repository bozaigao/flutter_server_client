import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_server_client/res/colors.dart';
import 'package:flutter_server_client/utils/date_util.dart';
import 'package:flutter_server_client/utils/functions.dart';
import 'package:flutter_server_client/utils/nim_plugin/flutter_nim_plugin.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/message_entity.dart';
import 'package:flutter_server_client/utils/object_util.dart';
import 'package:flutter_server_client/utils/screen_util.dart';
import 'package:flutter_server_client/widgets/voice_button.dart';
import 'load_image.dart';

/*
* 对话页面中的widget
*/
class ChatItemWidgets {
  static Widget buildChatListItem(
      MessageEntity nextEntity, MessageEntity entity, dynamic decodeMap,
      {OnItemClick onResend, OnItemClick onItemClick}) {
    bool _isShowTime = true;
    var showTime; //最终显示的时间
    if (null == nextEntity) {
      _isShowTime = true;
    } else {
      //如果当前消息的时间和上条消息的时间相差，大于5分钟，则要显示当前消息的时间，否则不显示
      if ((entity.timestamp - nextEntity.timestamp).abs() > 5 * 60 * 1000) {
        _isShowTime = true;
      } else {
        _isShowTime = false;
      }
    }
    //获取当前的时间,yyyy-MM-dd HH:mm
    String nowTime = DateUtil.getDateStrByMs(
        new DateTime.now().millisecondsSinceEpoch,
        format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE);
    //当前消息的时间,yyyy-MM-dd HH:mm
    String indexTime = DateUtil.getDateStrByMs(
        double.parse(entity.timestamp.toString()).toInt(),
        format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE);

    if (DateUtil.formatDateTime1(indexTime, DateFormat.YEAR) !=
        DateUtil.formatDateTime1(nowTime, DateFormat.YEAR)) {
      //对比年份,不同年份，直接显示yyyy-MM-dd HH:mm
      showTime = indexTime;
    } else if (DateUtil.formatDateTime1(indexTime, DateFormat.YEAR_MONTH) !=
        DateUtil.formatDateTime1(nowTime, DateFormat.YEAR_MONTH)) {
      //年份相同，对比年月,不同月或不同日，直接显示MM-dd HH:mm
      showTime =
          DateUtil.formatDateTime1(indexTime, DateFormat.MONTH_DAY_HOUR_MINUTE);
    } else if (DateUtil.formatDateTime1(indexTime, DateFormat.YEAR_MONTH_DAY) !=
        DateUtil.formatDateTime1(nowTime, DateFormat.YEAR_MONTH_DAY)) {
      //年份相同，对比年月,不同月或不同日，直接显示MM-dd HH:mm
      showTime =
          DateUtil.formatDateTime1(indexTime, DateFormat.MONTH_DAY_HOUR_MINUTE);
    } else {
      //否则HH:mm
      showTime = DateUtil.formatDateTime1(indexTime, DateFormat.HOUR_MINUTE);
    }

    return Container(
      child: Column(
        children: <Widget>[
          _isShowTime
              ? Center(
                  heightFactor: 2,
                  child: Text(
                    showTime,
                    style: TextStyle(color: MyColors.transparent_50),
                  ))
              : SizedBox(height: 0),
          _chatItemWidget(entity, decodeMap, onResend, onItemClick)
        ],
      ),
    );
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-13
  /// *@Description: 消息体
  static Widget _chatItemWidget(MessageEntity entity, dynamic decodeMap,
      OnItemClick onResend, OnItemClick onItemClick) {
    if (!entity.isOutgoingMsg) {
      //对方的消息
      return Container(
        margin: EdgeInsets.only(left: 10, right: 100, bottom: 30, top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _headPortrait('', 1),
            SizedBox(width: 10),
            new Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 5),
                GestureDetector(
                  child: _contentWidget(entity, decodeMap),
                  onTap: () {
                    if (null != onItemClick) {
                      onItemClick(entity);
                    }
                  },
                  onLongPress: () {
                    print('长按了消息');
                  },
                ),
              ],
            )),
          ],
        ),
      );
    } else {
      //自己的消息
      return Container(
        margin: EdgeInsets.only(left: 100, right: 10, bottom: 30, top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 5),
                GestureDetector(
                  child: _contentWidget(entity, decodeMap),
                  onTap: () {
                    if (null != onItemClick) {
                      onItemClick(entity);
                    }
                  },
                  onLongPress: () {
                    print('长按了消息');
                  },
                ),
                //显示是否重发1、发送2中按钮，发送成功0或者null不显示
                entity.deliveryState ==
                        getStringFromEnum(NIMMessageDeliveryState
                            .NIMMessageDeliveryStateFailed)
                    ? IconButton(
                        icon: Icon(Icons.refresh, color: Colors.red, size: 18),
                        onPressed: () {
                          if (null != onResend) {
                            onResend(entity);
                          }
                        })
                    : (entity.deliveryState ==
                            getStringFromEnum(NIMMessageDeliveryState
                                .NIMMessageDeliveryStateDelivering)
                        ? Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 20, right: 20),
                            width: 32.0,
                            height: 32.0,
                            child: SizedBox(
                                width: 12.0,
                                height: 12.0,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      MyColors.themeColor),
                                  strokeWidth: 2,
                                )),
                          )
                        : SizedBox(
                            width: 0,
                            height: 0,
                          )),
              ],
            )),
            SizedBox(width: 10),
            _headPortrait('', 0),
          ],
        ),
      );
    }
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-13
  /// *@Description: 用户头像
  static Widget _headPortrait(String url, int owner) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: url.isEmpty
            ? LoadImage(
                'https://pic.guigug.com/tou.png',
                width: 44,
                height: 44,
              )
            : (ObjectUtil.isNetUri(url)
                ? Image.network(
                    url,
                    width: 44,
                    height: 44,
                    fit: BoxFit.fill,
                  )
                : Image.asset(url, width: 44, height: 44)));
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-13
  /// *@Description: 消息内容
  static Widget _contentWidget(MessageEntity entity, dynamic decodeMap) {
    Widget widget;
    if (entity.messageType ==
            getStringFromEnum(NIMMessageType.NIMMessageTypeText) ||
        entity.messageType == 'text') {
      if (entity.text == null) {
        entity.text = '';
      }
      widget = buildTextWidget(entity, decodeMap);
    } else if (entity.messageType ==
        getStringFromEnum(NIMMessageType.NIMMessageTypeImage)||
        entity.messageType == 'image') {
      widget = buildImageWidget(entity);
    } else if (entity.messageType ==
        getStringFromEnum(NIMMessageType.NIMMessageTypeAudio)||
        entity.messageType == 'audio') {
      widget = VoiceButton(
        entity: entity,
      );
    } else if (entity.messageType ==
        getStringFromEnum(NIMMessageType.NIMMessageTypeCustom)||
        entity.messageType == 'custom') {
      if (entity.messageObject['type'] == 'Question') {
        widget = buildMessageTemplate(entity);
      } else if (entity.messageObject['type'] == 'JIFEN') {
        widget = buildJiFenMessage(entity);
      }
    }
    return widget;
  }

  static Widget buildMessageTemplate(MessageEntity entity) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(scaleSize(10)),
          color: Colors.white),
      child: Column(
          children: _buildItems(entity.messageObject['content']['title'],
              entity.messageObject['content']['questions'])),
    );
  }

  static List<Widget> _buildItems(String title, List questions) {
    List<Widget> widgets = List();
    widgets.add(Container(
      margin: EdgeInsets.all(scaleSize(10)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: setSp(16),
        ),
      ),
    ));
    widgets.add(Container(
      height: 1,
      color: MyColors.pageDefaultBackgroundColor,
    ));
    if (questions != null) {
      for (int i = 0; i < questions.length; i++) {
        widgets.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: scaleSize(7),
              height: scaleSize(7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(scaleSize(3.5)),
                  color: Color(0xffc3d0e1)),
              margin: EdgeInsets.only(left: scaleSize(10)),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: scaleSize(10),
                  bottom: scaleSize(10),
                  top: scaleSize(10)),
              width: scaleSize(170),
              child: Text(questions[i],
                  style: TextStyle(
                      fontSize: setSp(16), color: MyColors.themeColor)),
            ),
          ],
        ));
        if (i != questions.length - 1) {
          widgets.add(Container(
            height: 1,
            color: MyColors.pageDefaultBackgroundColor,
          ));
        }
      }
    }

    return widgets;
  }

  static Widget buildJiFenMessage(MessageEntity entity) {
    return Container(
      width: scaleSize(250),
      height: scaleSize(90),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: scaleSize(10)),
            child: LoadImage(
              entity.messageObject['data']['icon'],
              width: scaleSize(69),
              height: 68,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: scaleSize(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  entity.messageObject['data']['title'],
                  style:
                      TextStyle(fontSize: setSp(14), color: Color(0xff182222)),
                ),
                Container(
                  margin: EdgeInsets.only(top: scaleSize(13)),
                  child: Row(
                    children: <Widget>[
                      Text(
                        entity.messageObject['data']['integral'].toString(),
                        style: TextStyle(
                            fontSize: setSp(12), color: Color(0xffff7f26)),
                      ),
                      Text(
                        '积分',
                        style: TextStyle(
                            fontSize: setSp(12), color: Color(0xffaeaeae)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-13
  /// *@Description: 文本消息
  static Widget buildTextWidget(MessageEntity entity, dynamic decodeMap) {
    String showText = entity.text;
    List<String> showTextArray = List();
    RegExp exp = new RegExp(r"\[[^\]]+\]");
    Iterable<Match> matches = exp.allMatches(entity.text);
    for (Match m in matches) {
      String match = m.group(0);
      int wordIndex = showText.indexOf(match);
      if (wordIndex > 0) {
        showTextArray.add(showText.substring(0, wordIndex));
        showText = showText.substring(wordIndex);
      }
      showTextArray.add(match);
      showText = showText.substring(match.length);
    }
    if (showText.length > 0) {
      showTextArray.add(showText);
    }

    List<Widget> widgetList = [];

    for (String text in showTextArray) {
      if (exp.allMatches(text).length != 0 && decodeMap['$text'] != null) {
        String imageName = decodeMap['$text'];
        widgetList.add(LoadImage(
          imageName.substring(0, imageName.indexOf('.')),
          dir: 'face',
          format: 'gif',
          width: scaleSize(20),
          height: scaleSize(20),
        ));
      } else {
        widgetList.add(Text(
          text,
          style: TextStyle(
              fontSize: 16,
              color: entity.isOutgoingMsg ? Colors.white : Colors.black),
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: entity.isOutgoingMsg ? MyColors.themeColor : Colors.white),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Wrap(direction: Axis.horizontal, children: widgetList),
      ),
    );
  }

  static Widget buildImageWidget(MessageEntity entity) {
    double realWidth = double.parse(entity.messageObject['size']['width']);
    double realHeight = double.parse(entity.messageObject['size']['height']);
    //图像
    double width = ScreenUtil.screenWidthDp / 2;
    double height = realHeight > 0 ? ((width / realWidth) * realHeight) : width;
    String imagePath = '';
    bool isNetImage = entity.messageObject['thumbUrl'] != null &&
        entity.messageObject['thumbUrl'].toString().contains('http');
    if (isNetImage) {
      imagePath = entity.messageObject['thumbUrl'];
    } else {
      imagePath = entity.messageObject['path'];
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        child: isNetImage
            ? LoadImage(
                imagePath,
                width: width,
                height: height,
              )
            : Image.file(
                File(imagePath),
                width: width,
                height: height,
              ),
      ),
    );

    return SizedBox();
  }
}
