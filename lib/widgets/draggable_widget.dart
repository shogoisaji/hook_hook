import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hook_hook/models/hook_item.dart';
import 'package:hook_hook/state/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final isTouchHook = useState<bool>(false);
    final currentRelativePosition = useState<RelativeItemPosition>(RelativeItemPosition.topLeft);
    double positionDiffX = pinPosition.dx - itemHookPosition.value.dx;
    double positionDiffY = pinPosition.dy - itemHookPosition.value.dy;

    bool _isHooked = ref.watch(isHookedNotifierProvider);

    const itemSize = 200.0;

    void checkHooked() {
      print('${positionDiffX} ${positionDiffY} ${hookItem.hookRadius}}');
      if ((positionDiffX).abs() < hookItem.hookRadius && (positionDiffY).abs() < hookItem.hookRadius) {
        ref.read(isHookedNotifierProvider.notifier).hooked();
        print('hooked');
      } else {
        ref.read(isHookedNotifierProvider.notifier).unhooked();
      }
    }

    void checkRelativePosition() {
      if (positionDiffX < 0 && positionDiffY < 0) {
        currentRelativePosition.value = RelativeItemPosition.bottomRight;
      } else if (positionDiffX < 0 && positionDiffY > 0) {
        currentRelativePosition.value = RelativeItemPosition.topRight;
      } else if (positionDiffX > 0 && positionDiffY < 0) {
        currentRelativePosition.value = RelativeItemPosition.bottomLeft;
      } else if (positionDiffX > 0 && positionDiffY > 0) {
        currentRelativePosition.value = RelativeItemPosition.topLeft;
      }
    }

    void itemMove(deltaX, deltaY) {
      checkRelativePosition();
      if (currentRelativePosition.value == RelativeItemPosition.topRight) {
        itemHookPosition.value = Offset(
          itemHookPosition.value.dx + deltaX,
          itemHookPosition.value.dy + deltaY,
        );
        checkHooked();
      }
      // Hookにかかっている場合
      if (_isHooked) {
        if (deltaX > 0 && deltaY < 0) {
          itemHookPosition.value = Offset(
            itemHookPosition.value.dx + deltaX,
            itemHookPosition.value.dy + deltaY,
          );
          checkHooked();
        } else if ((positionDiffX).abs() > hookItem.hookRadius - 5 || (positionDiffY).abs() > hookItem.hookRadius - 5) {
          return;
        } else {
          itemHookPosition.value = Offset(
            itemHookPosition.value.dx + deltaX,
            itemHookPosition.value.dy + deltaY,
          );
          checkHooked();
        }
      }
      // Hookに触っている場合
      print("${currentRelativePosition.value} ${deltaX}  ${deltaY}");
      if ((positionDiffX).abs() < hookItem.hookRadius + 10 && (positionDiffY).abs() < hookItem.hookRadius + 10) {
        switch (currentRelativePosition.value) {
          case RelativeItemPosition.topLeft:
            if (deltaX > 0 || deltaY > 0) return;
            break;
          case RelativeItemPosition.topRight:
            // if (deltaX < 0 || deltaY > 0) return;
            break;
          case RelativeItemPosition.bottomLeft:
            if (deltaX > 0 || deltaY < 0) return;
            break;
          case RelativeItemPosition.bottomRight:
            if (deltaX < 0 || deltaY < 0) return;
            break;
          default:
            itemHookPosition.value = Offset(
              itemHookPosition.value.dx + deltaX,
              itemHookPosition.value.dy + deltaY,
            );
            checkHooked();
        }
      }
      itemHookPosition.value = Offset(
        itemHookPosition.value.dx + deltaX,
        itemHookPosition.value.dy + deltaY,
      );
      checkHooked();
    }

    // useEffect(() {
    //   return () {
    //     print(hookItemPosition.value);
    //   };
    // }, [hookItemPosition]);

    return Positioned(
      left: itemHookPosition.value.dx - itemSize / 2,
      top: itemHookPosition.value.dy - itemSize / 2,
      child: Draggable(
        onDragUpdate: (details) {
          itemMove(details.delta.dx, details.delta.dy);
        },
        onDragEnd: (details) {
          if (_isHooked) {
            return;
          }
          itemHookPosition.value = _initialHookItemPosition;
        },
        feedback: const SizedBox(
          width: itemSize,
          height: itemSize,
        ),
        child: const SizedBox(
          width: itemSize,
          height: itemSize,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: itemSize,
                  height: itemSize,
                  child: Image(
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
        // childWhenDragging: Container(
        //   width: itemSize,
        //   height: itemSize,
        //   color: Colors.transparent,
        // ),
      ),
    );
  }
}
