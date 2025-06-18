import 'package:flutter/material.dart';
import 'control_base.dart';
import 'control_event.dart';
import 'gamepad_keys.dart';

class ButtonControl extends ControlBase {
  final String label;
  final Color color;
  final int keyCode; // 按键码
  final bool isGamepadButton; // 是否是手柄按钮
  final bool isMouseButton; // 是否是鼠标按钮

  ButtonControl({
    required super.id,
    required super.centerX,
    required super.centerY,
    required super.size,
    required this.label,
    required this.keyCode,
    this.color = Colors.blue,
    this.isGamepadButton = false, // 默认为键盘按钮
    this.isMouseButton = false, // 默认为非鼠标按钮
  }) : super(
          type: 'button',
        );

  factory ButtonControl.fromMap(Map<String, dynamic> map) {
    return ButtonControl(
      id: map['id'],
      centerX: map['centerX'],
      centerY: map['centerY'],
      size: map['size'],
      label: map['label'] ?? 'Button',
      keyCode: map['keyCode'] ?? 0,
      color: Color(map['color'] ?? Colors.blue.value),
      isGamepadButton: map['isGamepadButton'] ?? false,
      isMouseButton: map['isMouseButton'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'centerX': centerX,
      'centerY': centerY,
      'size': size,
      'label': label,
      'keyCode': keyCode,
      'color': color.value,
      'isGamepadButton': isGamepadButton,
      'isMouseButton': isMouseButton,
    };
  }

  @override
  Widget buildWidget(
    BuildContext context, {
    required double screenWidth,
    required double screenHeight,
    required Function(ControlEvent) onEvent,
  }) {
    return _ButtonWidget(
      control: this,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      onEvent: onEvent,
      isGamepadButton: isGamepadButton,
      isMouseButton: isMouseButton,
    );
  }

  @override
  void handleEvent(ControlEvent event) {
    // 按钮事件处理
  }
}

class _ButtonWidget extends StatefulWidget {
  final ButtonControl control;
  final double screenWidth;
  final double screenHeight;
  final Function(ControlEvent) onEvent;
  final bool isGamepadButton;
  final bool isMouseButton;

  const _ButtonWidget({
    required this.control,
    required this.screenWidth,
    required this.screenHeight,
    required this.onEvent,
    required this.isGamepadButton,
    required this.isMouseButton,
  });

  @override
  State<_ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<_ButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final diameter = widget.screenWidth * widget.control.size;

    return Positioned(
      left: widget.screenWidth * widget.control.centerX - diameter / 2,
      bottom: widget.screenHeight * (1 - widget.control.centerY) - diameter / 2,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          if (widget.isMouseButton) {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.mouseButton,
              data: MouseButtonEvent(
                buttonId: widget.control.keyCode,
                isDown: true,
              ),
            ));
          } else if (widget.isGamepadButton) {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.gamepad,
              data: GamepadButtonEvent(
                keyCode: widget.control.keyCode,
                isDown: true,
              ),
            ));
          } else {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.keyboard,
              data: KeyboardEvent(
                keyCode: widget.control.keyCode,
                isDown: true,
              ),
            ));
          }
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (widget.isMouseButton) {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.mouseButton,
              data: MouseButtonEvent(
                buttonId: widget.control.keyCode,
                isDown: false,
              ),
            ));
          } else if (widget.isGamepadButton) {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.gamepad,
              data: GamepadButtonEvent(
                keyCode: widget.control.keyCode,
                isDown: false,
              ),
            ));
          } else {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.keyboard,
              data: KeyboardEvent(
                keyCode: widget.control.keyCode,
                isDown: false,
              ),
            ));
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          if (widget.isMouseButton) {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.mouseButton,
              data: MouseButtonEvent(
                buttonId: widget.control.keyCode,
                isDown: false,
              ),
            ));
          } else if (widget.isGamepadButton) {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.gamepad,
              data: GamepadButtonEvent(
                keyCode: widget.control.keyCode,
                isDown: false,
              ),
            ));
          } else {
            widget.onEvent(ControlEvent(
              eventType: ControlEventType.keyboard,
              data: KeyboardEvent(
                keyCode: widget.control.keyCode,
                isDown: false,
              ),
            ));
          }
        },
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: widget.control.color.withOpacity(_isPressed ? 0.7 : 0.4),
            borderRadius: BorderRadius.circular(diameter / 2),
          ),
          child: Center(
            child: Text(
              widget.control.label,
              style: TextStyle(
                color: /*Theme.of(context).textTheme.bodyLarge?.color ?? */
                    Colors.white,
                fontSize: diameter * 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
