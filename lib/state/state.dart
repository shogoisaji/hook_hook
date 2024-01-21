import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'state.g.dart';

///
/// Generate Command:
/// flutter pub run build_runner build --delete-conflicting-outputs
///

@riverpod
class IsHookedNotifier extends _$IsHookedNotifier {
  @override
  bool build() => false;

  void hooked() => state = true;
  void unhooked() => state = false;
}
