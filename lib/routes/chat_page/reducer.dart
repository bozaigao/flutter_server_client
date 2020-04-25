import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';

Reducer<ChatState> buildReducer() {
  return asReducer(
    <Object, Reducer<ChatState>>{
      ChatAction.resetShow: _resetShow,
      ChatAction.updateSendState: _updateSendState,
      ChatAction.updateVoiceState: _updateVoiceState,
      ChatAction.updateFaceState: _updateFaceState,
      ChatAction.updateToolsState: _updateToolsState,
      ChatAction.updateFaceFirstList: _updateFaceFirstList,
      ChatAction.updateMessageList: _updateMessageList,
      ChatAction.updateGuideFaceList: _updateGuideFaceList,
      ChatAction.initJsonCodeMap: _initJsonCodeMap,
      ChatAction.initJsonDecodeMap: _initJsonDecodeMap,
      ChatAction.initTimer: _initTimer,
      ChatAction.updateRecordState: _updateRecordState,
    },
  );
}

ChatState _updateRecordState(ChatState state, Action action) {
  return state.clone()
    ..recording = action.payload;
}


ChatState _initTimer(ChatState state, Action action) {
  return state.clone()
    ..timer = action.payload;
}

ChatState _resetShow(ChatState state, Action action) {
  return state.clone()
    ..isShowFace = false
    ..isShowTools = false
    ..isShowVoice = false;
}

ChatState _updateSendState(ChatState state, Action action) {
  return state.clone()..isShowSend = action.payload;
}

ChatState _updateVoiceState(ChatState state, Action action) {
  return state.clone()..isShowVoice = action.payload;
}

ChatState _updateFaceState(ChatState state, Action action) {
  return state.clone()..isShowFace = action.payload;
}

ChatState _updateToolsState(ChatState state, Action action) {
  return state.clone()..isShowTools = action.payload;
}

ChatState _updateFaceFirstList(ChatState state, Action action) {
  return state.clone()..isFaceFirstList = action.payload;
}

ChatState _updateMessageList(ChatState state, Action action) {
  return state.clone()..messageList = action.payload;
}

ChatState _updateGuideFaceList(ChatState state, Action action) {
  return state.clone()..guideFaceList = action.payload;
}

ChatState _initJsonCodeMap(ChatState state, Action action) {
  return state.clone()..jsonCodeMap = action.payload;
}

ChatState _initJsonDecodeMap(ChatState state, Action action) {
  return state.clone()..jsonDecodeMap = action.payload;
}
