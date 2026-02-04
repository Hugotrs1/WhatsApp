import 'package:flutter/material.dart';
import 'package:whatsapp/utils/appColors.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.radius = 22,
    this.highlight = false,
    this.muted = false,
  });

  final String initials;
  final String? imageUrl;
  final double radius;
  final bool highlight;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final borderColor = muted ? Colors.grey.shade400 : AppColors.lightPrimary;
    return Container(
      padding: EdgeInsets.all(highlight ? 2 : 0),
      decoration: highlight
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [borderColor, AppColors.primary],
              ),
            )
          : null,
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: ClipOval(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final provider = _resolveImage(imageUrl);
    if (provider == null) return _FallbackAvatar(initials: initials);
    return Image(
      image: provider,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _FallbackAvatar(initials: initials),
    );
  }

  ImageProvider? _resolveImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('asset:')) return AssetImage(url.substring(6));
    if (url.startsWith('assets/')) return AssetImage(url);
    // Skip remote URLs to avoid SSL/host errors; rely on fallback instead.
    return null;
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
