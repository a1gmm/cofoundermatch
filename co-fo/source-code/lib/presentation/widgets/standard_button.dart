import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StandardButton extends StatefulWidget {
  const StandardButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.color,
    this.width,
    this.height,
  });
  final String text;
  final Color? color;
  final void Function()? onPressed;
  final double? width;
  final double? height;

  @override
  State<StandardButton> createState() => _StandardButtonState();
}

class _StandardButtonState extends State<StandardButton> {
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: widget.onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: widget.color ?? Theme.of(context).primaryColor,
        minimumSize: Size(widget.width ?? .5.sw, widget.height ?? 40.h),
        maximumSize: Size(widget.width ?? .5.sw, widget.height ?? 40.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(
        widget.text,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
