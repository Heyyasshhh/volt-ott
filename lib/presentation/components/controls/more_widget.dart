import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:volt/constants/colors.dart';

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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.colorHairline)),
          ),
          child: Row(
            children: [
              widget.svgIconPath != null
                  ? SvgPicture.asset(
                      widget.svgIconPath!,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        AppColors.colorAccent,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      widget.icon,
                      color: AppColors.colorAccent,
                      size: 18,
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.colorTextMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
