import 'dart:async';

import 'package:flutter/cupertino.dart';

class DebouncingController extends TextEditingController {
  final Duration delay;
  VoidCallback? _callback;
  Timer? _timer;

  DebouncingController({required this.delay});

  void run(VoidCallback callback) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _callback = callback;
    _timer = Timer(delay, _executeCallback);
  }

  void _executeCallback() {
    _callback?.call();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _callback = null;
  }
}
