import 'package:fish_redux/fish_redux.dart';

//TODO replace with your own action
enum PhotoViewAction { action }

class PhotoViewActionCreator {
  static Action onAction() {
    return const Action(PhotoViewAction.action);
  }
}
