import 'package:fish_redux/fish_redux.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class SessionPage extends Page<SessionState, Map<String, dynamic>> with WidgetsBindingObserverMixin<SessionState>{
  SessionPage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<SessionState>(
                adapter: null,
                slots: <String, Dependent<SessionState>>{
                }),
            middleware: <Middleware<SessionState>>[
            ],);

}
