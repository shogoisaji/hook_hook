import 'package:flutter/material.dart';
import 'package:hook_hook/models/draggable_item.dart';

enum ItemType { dog, cat, horse }

class HookItem extends DraggableItem {
  final int id;
  final ItemType itemType;
  final Offset position;
  final double itemAngle;

  HookItem({
    required this.id,
    required this.itemType,
    required this.position,
    required this.itemAngle,
  });
}
