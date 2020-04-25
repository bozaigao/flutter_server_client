import 'package:fish_redux/fish_redux.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class PhotoViewPage extends Page<PhotoViewState, String> {
  PhotoViewPage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<PhotoViewState>(
                adapter: null,
                slots: <String, Dependent<PhotoViewState>>{
                }),
            middleware: <Middleware<PhotoViewState>>[
            ],);

}
