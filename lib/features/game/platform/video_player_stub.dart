import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E0E0E),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, color: Color(0xFFC49830), size: 48),
            SizedBox(height: 8),
            Text('الفيديو متاح على الويب فقط',
                style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF5A4820), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

void registerVideoPlayer(String viewType, String url) {}