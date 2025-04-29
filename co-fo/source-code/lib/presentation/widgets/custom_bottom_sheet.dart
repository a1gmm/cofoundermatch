import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({
    super.key,
    required this.text,
    required this.child,
    this.onOpen,
  });
  final Widget text;
  final Widget child;
  final VoidCallback? onOpen;

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  void _showBottomSheet(BuildContext context) {
    if (widget.onOpen != null) {
      widget.onOpen!(); // Call the provided function when sheet opens
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: widget.child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(),
      padding: MediaQuery.of(context).viewInsets,
      child: widget.text.onTap(() => _showBottomSheet(context)),
    );
  }
}
