import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoreWidget extends StatefulWidget {
  final String text;
  final IconData? icon;
  final String? svgIconPath;
  final VoidCallback onPressed;

  const MoreWidget({
    super.key,
    required this.text,
    this.icon,
    this.svgIconPath,
    required this.onPressed,
  }) : assert(icon != null || svgIconPath != null, 'Either icon or svgIconPath must be provided');

  @override
  State<MoreWidget> createState() => _MoreWidgetState();
}

class _MoreWidgetState extends State<MoreWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              widget.svgIconPath != null
                  ? SvgPicture.asset(
                      widget.svgIconPath!,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 28,
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
