import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hook_hook/models/hook_item.dart';
import 'package:hook_hook/state/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';

enum RelativeItemPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class DraggableWidget extends HookConsumerWidget {
  final Offset pinPosition;
  final HookItem hookItem;
  DraggableWidget({super.key, required this.hookItem, required this.pinPosition});

  final _initialHookItemPosition = Offset(200, 200);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemHookPosition = useState<Offset>(_initialHookItemPosition);
    final isDragged = useState<bool>(false);
    // final currentRelativePosition = useState<RelativeItemPosition>(RelativeItemPosition.topLeft);
    double positionDiffX = pinPosition.dx - itemHookPosition.value.dx;
    double positionDiffY = pinPosition.dy - itemHookPosition.value.dy;
    // ピンとフックアイテムの距離
    final double diff =
        sqrt(pow(pinPosition.dx - itemHookPosition.value.dx, 2) + pow(pinPosition.dy - itemHookPosition.value.dy, 2));

    bool _isHooked = ref.watch(isHookedNotifierProvider);

    RelativeItemPosition checkRelativePosition() {
      if (positionDiffX < 0 && positionDiffY < 0) {
        return RelativeItemPosition.bottomRight;
      } else if (positionDiffX < 0 && positionDiffY > 0) {
        return RelativeItemPosition.topRight;
      } else if (positionDiffX > 0 && positionDiffY < 0) {
        return RelativeItemPosition.bottomLeft;
      } else if (positionDiffX > 0 && positionDiffY > 0) {
        return RelativeItemPosition.topLeft;
      }
      return RelativeItemPosition.topLeft;
    }

    void move(deltaX, deltaY) {
      // 移動後のピンとフックアイテムの距離
      final double nextDiff = sqrt(pow(pinPosition.dx - itemHookPosition.value.dx - deltaX, 2) +
          pow(pinPosition.dy - itemHookPosition.value.dy - deltaY, 2));

      final currentRelativePosition = checkRelativePosition();
      if (currentRelativePosition == RelativeItemPosition.topRight) {
        itemHookPosition.value = Offset(
          itemHookPosition.value.dx + deltaX,
          itemHookPosition.value.dy + deltaY,
        );
      } else if (_isHooked) {
        if (deltaX > 0 && deltaY < 0) {
          itemHookPosition.value = Offset(
            itemHookPosition.value.dx + deltaX,
            itemHookPosition.value.dy + deltaY,
          );
        } else if (nextDiff < hookItem.hookRadius - 4) {
          itemHookPosition.value = Offset(
            itemHookPosition.value.dx + deltaX,
            itemHookPosition.value.dy + deltaY,
          );
        } else {
          return;
        }
      } else if (currentRelativePosition == RelativeItemPosition.topRight) {
        // itemHookPosition.value = Offset(
        //   itemHookPosition.value.dx + deltaX,
        //   itemHookPosition.value.dy + deltaY,
        // );
      } else if (nextDiff < hookItem.hookRadius + 13) {
        return;
      } // Hook Thickness 13
      else {
        itemHookPosition.value = Offset(
          itemHookPosition.value.dx + deltaX,
          itemHookPosition.value.dy + deltaY,
        );
      }
    }

    void checkHooked() {
      if (diff < hookItem.hookRadius) {
        ref.read(isHookedNotifierProvider.notifier).hooked();
        print('hooked');
      } else {
        ref.read(isHookedNotifierProvider.notifier).unhooked();
      }
    }

    void itemMove(deltaX, deltaY) {
      // final RelativeItemPosition relativePosition = checkRelativePosition();
      checkHooked();
      // if (relativePosition == RelativeItemPosition.topRight) {
      //   move(deltaX, deltaY);
      // }
      // Hookにかかっている場合
      if (_isHooked) {
        //右上へは動かせる
        if (deltaX > 0 && deltaY < 0) {
          move(deltaX, deltaY);
          // } else if ((d).abs() > hookItem.hookRadius - 5 || (positionDiffY).abs() > hookItem.hookRadius - 5) {
          //   return;
        } else {
          move(deltaX, deltaY);
        }
      }
      // Hookに触っている場合
      // else if ((positionDiffX).abs() - deltaX.abs() < hookItem.hookRadius + 10 &&
      //     (positionDiffY).abs() - deltaX.abs() < hookItem.hookRadius + 10) {
      //   return;
      //   switch (relativePosition) {
      //     case RelativeItemPosition.topLeft:
      //       if (deltaX > 0 || deltaY > 0) return;
      //       break;
      //     case RelativeItemPosition.topRight:
      //       // if (deltaX < 0 || deltaY > 0) return;
      //       break;
      //     case RelativeItemPosition.bottomLeft:
      //       if (deltaX > 0 || deltaY < 0) return;
      //       break;
      //     case RelativeItemPosition.bottomRight:
      //       if (deltaX < 0 || deltaY < 0) return;
      //       break;
      //     default:
      //       move(deltaX, deltaY);
      //   }
      // }
      move(deltaX, deltaY);
    }

    // useEffect(() {
    //   return () {
    //     print(hookItemPosition.value);
    //   };
    // }, [hookItemPosition]);

    return Positioned(
      left: itemHookPosition.value.dx - hookItem.size / 2,
      top: itemHookPosition.value.dy - hookItem.size / 2,
      child: Draggable(
        onDragStarted: () {
          isDragged.value = true;
        },
        onDragUpdate: (details) {
          itemMove(details.delta.dx, details.delta.dy);
        },
        onDragEnd: (details) {
          isDragged.value = false;
          if (_isHooked) {
            return;
          }
          itemHookPosition.value = _initialHookItemPosition;
        },
        feedback: SizedBox(
          width: hookItem.size,
          height: hookItem.size,
        ),
        child: Transform.rotate(
          angle: isDragged.value ? 0.1 : 0.0,
          child: SizedBox(
            width: hookItem.size,
            height: hookItem.size,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: hookItem.size,
                    height: hookItem.size,
                    child: const Image(
                      image: AssetImage('assets/hook1.png'),
                    ),
                  ),
                ),
                // Center(
                //   child: CircleAvatar(
                //     backgroundColor: Colors.green,
                //     radius: 12,
                //   ),
                // ),
              ],
            ),
          ),
        ),
        // childWhenDragging: Container(
        //   width: itemSize,
        //   height: itemSize,
        //   color: Colors.transparent,
        // ),
      ),
    );
  }
}
