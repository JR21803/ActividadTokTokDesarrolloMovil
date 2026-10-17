import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String caption;
  final String videoUrl;

  const FullScreenPlayer({
    super.key,
    required this.caption,
    required this.videoUrl,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl);
    _initialization = _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_controller.value.isInitialized) return;
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<void>(
            future: _initialization,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Icon(Icons.error_outline, color: Colors.white),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              return FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 88,
            bottom: 28,
            child: Text(
              widget.caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
