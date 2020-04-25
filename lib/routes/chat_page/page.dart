import 'package:fish_redux/fish_redux.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class ChatPage extends Page<ChatState, ChatPageData> {
  ChatPage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<ChatState>(
                adapter: null,
                slots: <String, Dependent<ChatState>>{
                }),
            middleware: <Middleware<ChatState>>[
            ],);

}
