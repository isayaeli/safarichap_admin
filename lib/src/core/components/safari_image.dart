import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';

/// Cached network image with a neutral placeholder / error state.
class SafariImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SafariImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: safariChapColors.tertiaryColor!.withValues(alpha: 0.22),
      child: Icon(
        Icons.landscape_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    final image = url == null
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (_, _) => placeholder,
            errorWidget: (_, _, _) => placeholder,
          );
    return borderRadius == null
        ? image
        : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
