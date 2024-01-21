import 'package:flutter/material.dart';
import 'package:hook_hook/models/hook_item.dart';
import 'package:hook_hook/state/state.dart';
import 'package:hook_hook/widgets/draggable_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _isHooked = ref.watch(isHookedNotifierProvider);
    final _pinRadius = 4.0;
    final _pinPosition = Offset(200, 100);
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Container(
            width: double.infinity,
            height: 600,
            color: Colors.red[100],
            // color: _isHooked ? Colors.blue[100] : Colors.red[100],
            child: Stack(
              children: [
                Positioned(
                  top: _pinPosition.dy - _pinRadius,
                  left: _pinPosition.dx - _pinRadius,
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: _pinRadius,
                  ),
                ),
                DraggableWidget(
                  pinPosition: _pinPosition,
                  hookItem: HookItem(
                    id: 1,
                    itemType: ItemType.dog,
                    position: Offset(0, 0),
                    itemAngle: 0,
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
