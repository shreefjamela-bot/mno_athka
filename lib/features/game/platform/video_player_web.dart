// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: 'mno-video-player');
  }
}

void registerVideoPlayer(String viewType, String url) {
  ui.platformViewRegistry.registerViewFactory(viewType, (int id) {
    return html.VideoElement()
      ..src = url
      ..autoplay = false
      ..loop = true
      ..muted = true
      ..controls = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '12px';
  });
}