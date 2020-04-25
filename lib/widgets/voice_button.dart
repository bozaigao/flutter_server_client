import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_server_client/res/colors.dart';
import 'package:flutter_server_client/utils/common.dart';
import 'package:flutter_server_client/utils/flutter_sound/flutter_sound.dart';
import 'package:flutter_server_client/utils/image_utils.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/message_entity.dart';
import 'package:flutter_server_client/widgets/opacity_button.dart';
import '../app.dart';

class VoiceButton extends StatefulWidget {
  final MessageEntity entity;

  const VoiceButton({Key key, this.entity}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VoiceButtonState();
  }
}

class _VoiceButtonState extends State<VoiceButton> {
  double opacity = 1;
  bool isPlaying = false;
  FlutterSound flutterSoundPlayer = new FlutterSound();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterSoundPlayer.stopPlayer();
  }


  @override
  Widget build(BuildContext context) {
    double width;
    int duration = widget.entity.messageObject != null
        ? int.parse(widget.entity.messageObject['duration'])
        : 0;
    if (duration < 5000) {
      width = 90;
    } else if (duration < 10000) {
      width = 140;
    } else if (duration < 20000) {
      width = 180;
    } else {
      width = 200;
    }

    print('语音洗哦阿西${widget.entity.messageObject}');
    // TODO: implement build
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: OpacityButton(
        onTap: () {
          eventBus.on().listen((data) {
            if (data == Constant.resetAudio) {
              setState(() {
                isPlaying = false;
              });
            }
          });
          setState(() {
            isPlaying = true;
          });
          if (widget.entity.messageObject != null) {
            flutterSoundPlayer.startPlayer(widget.entity.messageObject['url'],(){
              setState(() {
                isPlaying = false;
              });
            });
          }
        },
        child: Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            width: width,
            color: !widget.entity.isOutgoingMsg
                ? Colors.white
                : MyColors.themeColor,
            child: Row(
              mainAxisAlignment: !widget.entity.isOutgoingMsg
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: <Widget>[
                !widget.entity.isOutgoingMsg
                    ? Text('')
                    : Text((duration ~/ 1000).toString() + 's',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(
                  width: 5,
                ),
                Image.asset(
                  isPlaying
                      ? ImageUtils.getImgPath('mic_play', format: 'gif')
                      : ImageUtils.getImgPath('mic_play'),
                  width: 18,
                  height: 18,
                  color: !widget.entity.isOutgoingMsg?Colors.black:Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                !widget.entity.isOutgoingMsg
                    ? Text((duration ~/ 1000).toString() + 's',
                        style: TextStyle(fontSize: 18, color: Colors.black))
                    : Text(''),
              ],
            )),
      ),
    );
  }
}
