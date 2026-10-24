import 'package:flutter/material.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';

class ProgressedButton extends StatelessWidget {
  final VoidCallback? onClick;
  final bool isEnabled;
  final bool isOutlined;
  final bool isLoading;
  final String text;
  final Color? textColor;
  final String? imageUrl;
  final double? imageHeight;
  final double? imageWidth;
  final Color? backgroundColor;

  const ProgressedButton({
    super.key,
    required this.text,
    required this.onClick,
    this.textColor,
    this.isEnabled = true,
    this.isLoading = false,
    this.isOutlined = false,
    this.imageUrl,
    this.imageHeight,
    this.imageWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final enableBtn = isEnabled && !isLoading;
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imageUrl != null) ...[
          Image.asset(imageUrl ?? "", height: imageHeight, width: imageWidth),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: TextStyle(
            // Filled buttons are gold → dark text; outlined use the theme.
            color:
                textColor ??
                (isOutlined ? null : safariChapColors.onPrimaryColor),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          isOutlined
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: backgroundColor,
                  ),
                  onPressed: enableBtn ? onClick : null,
                  child: content,
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        backgroundColor ?? safariChapColors.primaryColor,
                  ),
                  onPressed: enableBtn ? onClick : null,
                  child: content,
                ),
          Align(
            child: isLoading ? const CircularProgressIndicator() : Container(),
          ),
        ],
      ),
    );
  }
}
