import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/services/language.service.dart';

class VideoPlayerViewModel extends BaseViewModel {
  VideoPlayerController? _videoPlayerController;
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  ChewieController? _chewieController;
  ChewieController? get chewieController => _chewieController;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String? _currentVideoUrl;

  void init(String videoUrl) {
    _currentVideoUrl = videoUrl;
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      notifyListeners();

      _chewieController?.dispose();
      await _videoPlayerController?.dispose();

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(_currentVideoUrl!),
      );

      _videoPlayerController!.addListener(_videoListener);

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: false,

        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        autoInitialize: true,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage =
          '${LanguageService.get('failed_to_load_video')}: ${e.toString()}';
      notifyListeners();
    }
  }

  void _videoListener() {
    if (_videoPlayerController!.value.hasError) {
      _hasError = true;
      _errorMessage =
          _videoPlayerController!.value.errorDescription ??
          LanguageService.get('unknown_error');
      notifyListeners();
    }
  }

  void reinitializeVideo() {
    if (_currentVideoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
