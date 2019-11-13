import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_hw/gallery/demo/shrine/model/app_state_model.dart';
import 'package:flutter_hw/gallery/demos.dart';
import 'package:flutter_hw/gallery/options.dart';
import 'package:flutter_hw/gallery/scales.dart';
import 'package:flutter_hw/gallery/theme.dart';
import 'package:scoped_model/scoped_model.dart';

class GalleryApp extends StatefulWidget {
  // final UpdateU ;
  final bool enablePerformanceOverlay;
  final bool enableRasterCacheImagesCheckerboard;
  final bool enableOffscreenLayerCheckerboard;
  final VoidCallback onSendFeedback;
  final bool testMode;
  GalleryApp(
      {Key key,
      this.enablePerformanceOverlay = true,
      this.enableRasterCacheImagesCheckerboard = true,
      this.enableOffscreenLayerCheckerboard = true,
      this.onSendFeedback,
      this.testMode = false})
      : super(key: key);

  @override
  _GalleryAppState createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  GalleryOptions _options;
  Timer _timerDilationTimer;
  AppStateModel model;

  Map<String, WidgetBuilder> _buildRoutes() {
    return Map<String, WidgetBuilder>.fromIterable(
      kAllGalleryDemos,
      key: (dynamic t) => '${t.routeName}',
      value: (dynamic t) => t.buildRoute,
    );
  }

  @override
  void initState() {
    super.initState();
    _options = GalleryOptions(
      themeMode: ThemeMode.system,
      textScaleFactor: kAllGalleryTextScaleValues[0],
      timeDilation: timeDilation,
      targetPlatform: defaultTargetPlatform,
    );
    model = AppStateModel()..loadProducts();
  }

  @override
  void dispose() {
    _timerDilationTimer?.cancel();
    _timerDilationTimer = null;
    super.dispose();
  }

  void _handleOptionsChanged(GalleryOptions newOptions) {
    setState(() {
      if (_options.timeDilation != newOptions.timeDilation) {
        _timerDilationTimer?.cancel();
        _timerDilationTimer = null;
        if (newOptions.timeDilation > 1.0) {
          _timerDilationTimer = Timer(
            const Duration(microseconds: 150),
            () {
              timeDilation = newOptions.timeDilation;
            },
          );
        } else {
          timeDilation = newOptions.timeDilation;
        }
      }

      _options = newOptions;
    });
  }

  Widget _applyTextScaleFactor(Widget child) {
    return Builder(
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: _options.textScaleFactor.scale,
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Widget home = GallHome();

    // if (widget.updateUrlFetcher != null) {}

    return ScopedModel<AppStateModel>(
      model: model,
      child: MaterialApp(
        theme: kLightGalleryTheme,
        darkTheme: kDarkGalleryTheme,
        themeMode: _options.themeMode,
        title: 'Flutter Gallery',
        color: Colors.grey,
        showPerformanceOverlay: _options.showPerformanceOverlay,
        checkerboardOffscreenLayers: _options.showOffscreenLayersCheckerboard,
        checkerboardRasterCacheImages: _options.showRasterCacheImagesCheckerboard,
        routes: _buildRoutes(),
        builder: (BuildContext context, Widget child) {
          return Directionality(
            textDirection: _options.textDirection,
            child: _applyTextScaleFactor(
              Builder(
                builder: (BuildContext context) {
                  return CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: Theme.of(context).brightness,
                    ),
                    child: child,
                  );
                },
              ),
            ),
          );
        },
        home: Text('Home'),
      ),
    );
  }
}
