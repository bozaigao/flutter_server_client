import 'package:flutter/material.dart';
import 'package:flutter_server_client/utils/functions.dart';
import 'package:flutter_server_client/utils/image_util.dart';

class PopupWindowUtil {
  static Widget buildDivider({
    double height = 10,
    Color bgColor = const Color(0xffe5e5e5),
    double dividerHeight = 0.5,
    Color dividerColor = const Color(0xffe5e5e5),
  }) {
    BorderSide side = BorderSide(
        color: dividerColor, width: dividerHeight, style: BorderStyle.solid);
    return new Container(
        padding: EdgeInsets.all(height / 2),
        decoration: new BoxDecoration(
          color: bgColor,
          border: Border(top: side, bottom: side),
        ));
  }

  /*
  * 选择相机相册
  */
  static Future showPhotoChosen(BuildContext context, {dynamic onCallBack}) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.photo_camera),
                title: new Text("拍照"),
                onTap: () async {
                  Navigator.pop(context);
                  ImageUtil.getCameraImage().then((image) {
                    if (onCallBack != null) {
                      onCallBack(image);
                    }
                  });
                },
              ),
              buildDivider(height: 0),
              new ListTile(
                leading: new Icon(Icons.photo_library),
                title: new Text("相册"),
                onTap: () async {
                  Navigator.pop(context);
                  ImageUtil.getGalleryImage().then((image) {
                    if (onCallBack != null) {
                      onCallBack(image);
                    }
                  });
                },
              ),
            ],
          );
        });
  }

  /*
  * 选择拍照片、拍视频
  */
  static Future showCameraChosen(BuildContext context,
      {OnCallBackWithType onCallBack}) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.photo_camera),
                title: new Text("拍照片"),
                onTap: () async {
                  Navigator.pop(context);
                  ImageUtil.getCameraImage().then((image) {
                    if (onCallBack != null) {
                      onCallBack(1, image);
                    }
                  });
                },
              ),
             buildDivider(height: 0),
            ],
          );
        });
  }
}
