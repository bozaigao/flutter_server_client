import 'package:fish_redux/fish_redux.dart';
import 'action.dart';
import 'state.dart';

Effect<PhotoViewState> buildEffect() {
  return combineEffects(<Object, Effect<PhotoViewState>>{
    PhotoViewAction.action: _onAction,
  });
}

void _onAction(Action action, Context<PhotoViewState> ctx) {
}
