import 'package:fish_redux/fish_redux.dart';

class PhotoViewState implements Cloneable<PhotoViewState> {
  String image;

  @override
  PhotoViewState clone() {
    return PhotoViewState()..image = image;
  }
}

PhotoViewState initState(String image) {
  return PhotoViewState()
  ..image = image;
}