import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  const UserAvatar({super.key, this.url, this.radius = 22});
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    child: ClipOval(
      child: url == null || url!.isEmpty
          ? Icon(Icons.person, size: radius)
          : CachedNetworkImage(
              imageUrl: url!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              placeholder: (_, _) => Icon(Icons.person, size: radius),
              errorWidget: (_, _, _) => Icon(Icons.person, size: radius),
            ),
    ),
  );
}
