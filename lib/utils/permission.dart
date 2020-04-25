import 'package:permission_handler/permission_handler.dart';

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-04-13
/// *@Description: 申请读写权限
Future requestReadAndWritePermission() async {
  // 申请权限

  Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);

  // 申请结果

  PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

  if (permission == PermissionStatus.granted) {
    return Future.value(true);
  } else {
    return Future.value(false);
  }
}
