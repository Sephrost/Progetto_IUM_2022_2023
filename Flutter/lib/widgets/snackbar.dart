import 'package:flutter/material.dart';

class AltSnackbar extends SnackBar {
  final AltSnackbarType type;
  static const Color _onBackgourndColor = Colors.white;

  AltSnackbar({
    super.key,
    required this.type,
    String? text,
  }) : super(
          content: _content(text, type),
          backgroundColor: getBackgroundColor(type),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3), // default is 4 seconds
          margin: const EdgeInsets.only(
              // bottom: WidgetsBinding.instance.window.physicalSize.height /
              //         WidgetsBinding.instance.window.devicePixelRatio -
              //     WidgetsBinding.instance.window.padding.top /
              //         WidgetsBinding.instance.window.devicePixelRatio -
              //     50 -
              //     WidgetsBinding.instance.window.viewInsets.bottom,
              // 200,
              right: 10,
              left: 10,
              bottom: 3),
        );

  static Widget _content(String? text, AltSnackbarType type) {
    return Row(
      children: [
        Icon(
          type == AltSnackbarType.success
              ? Icons.check_circle_outline_rounded
              : type == AltSnackbarType.error
                  ? Icons.error_outline
                  : type == AltSnackbarType.warning
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
          color: _onBackgourndColor,
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          text ?? '',
          style: const TextStyle(color: _onBackgourndColor, fontSize: 16),
        ),
      ],
    );
  }

  static Color getBackgroundColor(type) {
    switch (type) {
      case AltSnackbarType.success:
        return const Color.fromRGBO(99, 142, 90, 0.8);
      case AltSnackbarType.error:
        return const Color.fromRGBO(255, 0, 0, 0.8);
      case AltSnackbarType.warning:
        return const Color.fromRGBO(232, 145, 72, 0.8);
      case AltSnackbarType.info:
        return const Color.fromRGBO(80, 147, 209, 0.8);
      default:
        return Colors.black;
    }
  }
}

enum AltSnackbarType { success, error, warning, info }
