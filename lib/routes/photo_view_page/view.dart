import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_server_client/res/colors.dart';
import 'package:photo_view/photo_view.dart';
import 'state.dart';

Widget buildView(
    PhotoViewState state, Dispatch dispatch, ViewService viewService) {
  return _buildWidget(viewService.context, state);
}

Widget _buildWidget(BuildContext context, PhotoViewState state) {
  List<Widget> _listWidget = new List();
  _listWidget.add(_itemWidget(state.image));
  return Container(
      child: GestureDetector(
        child: Swiper(
            autoStart: false,
            circular: false,
            indicator: CircleSwiperIndicator(
                radius: 4.0,
                padding: EdgeInsets.only(bottom: 20.0),
                itemColor: Color(0xFF999999),
                itemActiveColor: MyColors.themeColor),
            children: _listWidget),
        onTap: () {
          Navigator.pop(context);
        },
      ));
}

Widget _itemWidget(String url) {
  return PhotoView(
    imageProvider:
        url.startsWith("http") ? NetworkImage(url) : FileImage(File(url)),
  );
}
