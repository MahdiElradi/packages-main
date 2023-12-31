// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';

// `FutureOr<dynamic>` instead of `FutureOr<void>` to avoid
// "don't assign to void" warnings.
typedef AdditionalSteps = FutureOr<dynamic> Function(dynamic args);

class StubInAppPurchasePlatform {
  final Map<String, dynamic> _expectedCalls = <String, dynamic>{};
  final Map<String, AdditionalSteps?> _additionalSteps =
      <String, AdditionalSteps?>{};
  void addResponse(
      {required String name,
      dynamic value,
      AdditionalSteps? additionalStepBeforeReturn}) {
    _additionalSteps[name] = additionalStepBeforeReturn;
    _expectedCalls[name] = value;
  }

  final List<MethodCall> _previousCalls = <MethodCall>[];
  List<MethodCall> get previousCalls => _previousCalls;
  MethodCall previousCallMatching(String name) =>
      _previousCalls.firstWhere((MethodCall call) => call.method == name);
  int countPreviousCalls(String name) =>
      _previousCalls.where((MethodCall call) => call.method == name).length;

  void reset() {
    _expectedCalls.clear();
    _previousCalls.clear();
    _additionalSteps.clear();
  }

  Future<dynamic> fakeMethodCallHandler(MethodCall call) async {
    _previousCalls.add(call);
    if (_expectedCalls.containsKey(call.method)) {
      if (_additionalSteps[call.method] != null) {
        await _additionalSteps[call.method]!(call.arguments);
      }
      return Future<dynamic>.sync(() => _expectedCalls[call.method]);
    } else {
      return Future<void>.sync(() => null);
    }
  }
}
