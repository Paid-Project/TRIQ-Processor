import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

import 'video_player.vm.dart';

class VideoPlayerView extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerView({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VideoPlayerViewModel>.reactive(
      viewModelBuilder: () => VideoPlayerViewModel(),
      onViewModelReady: (model) => model.init(videoUrl),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, iconTheme: IconThemeData(color: Colors.white), elevation: 0),
          body: SafeArea(child: _buildVideoPlayer(context, model)),
        );
      },
    );
  }

  Widget _buildVideoPlayer(BuildContext context, VideoPlayerViewModel model) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
    }

    if (model.hasError) {
      return _buildErrorWidget(context, model);
    }

    if (model.chewieController == null) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
    }

    return Hero(tag: 'chat_video_$videoUrl', child: Chewie(controller: model.chewieController!));
  }

  Widget _buildErrorWidget(BuildContext context, VideoPlayerViewModel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Colors.white, size: 64),
        SizedBox(height: 16),
        Text(LanguageService.get('failed_to_load_video'), style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Text(model.errorMessage, style: TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => model.reinitializeVideo(),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: Text(LanguageService.get('retry')),
        ),
      ],
    );
  }
}
