import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uniapp/app/imports.dart';
import 'package:video_player/video_player.dart';

class GalleryGrid extends StatefulWidget {
  final List<String> mediaUrls;

  const GalleryGrid({super.key, required this.mediaUrls});

  @override
  State<GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends State<GalleryGrid> {
  @override
  Widget build(BuildContext context) {
    final count = widget.mediaUrls.length;
    if (count == 0) return const SizedBox.shrink();

    if (count == 1) return _buildMediaItem(widget.mediaUrls[0], 0, big: true);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count <= 2 ? count : 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: count,
      itemBuilder:
          (context, i) => _buildMediaItem(widget.mediaUrls[i], i, big: false),
    );
  }

  Widget _buildMediaItem(String url, int index, {required bool big}) {
    return GalleryMediaItem(
      key: ValueKey(url),
      url: url,
      onTap: () {
        _openFullScreenGallery(context, widget.mediaUrls, index);
      },
    );
  }

  void _openFullScreenGallery(
    BuildContext context,
    List<String> media,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FullScreenGallery(mediaUrls: media, initialIndex: index),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.mediaUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  bool _isVideo(String url) =>
      url.toLowerCase().contains('.mp4') || url.toLowerCase().contains("video");

  Future<Widget> _loadVideoPlayer(String url, int index) async {
    if (!_videoControllers.containsKey(index)) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.setLooping(false);
      controller.setVolume(1);
      controller.pause();
      _videoControllers[index] = controller;
    }
    final controller = _videoControllers[index]!;
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        _ControlsOverlay(controller: controller),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${_currentIndex + 1}/${widget.mediaUrls.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaUrls.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (_, i) {
          final url = widget.mediaUrls[i];
          if (_isVideo(url)) {
            return FutureBuilder<Widget>(
              future: _loadVideoPlayer(url, i),
              builder:
                  (_, snap) =>
                      snap.connectionState == ConnectionState.done
                          ? snap.data!
                          : const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
            );
          } else {
            return InteractiveViewer(
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            );
          }
        },
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  bool _visible = true;
  Duration _current = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    _updateDurations();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {
      _current = widget.controller.value.position;
      _total = widget.controller.value.duration;
    });
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  void _updateDurations() {
    final value = widget.controller.value;
    _current = value.position;
    _total = value.duration;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.controller.value.isPlaying;

    return GestureDetector(
      onTap: () {
        setState(() {
          _visible = !_visible;
        });
      },
      child: Stack(
        children: [
          if (!isPlaying)
            const Center(
              child: Icon(
                Symbols.play_arrow_rounded,
                color: Colors.white,
                size: 60,
                fill: 1,
              ),
            ),

          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _visible || !isPlaying ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: _togglePlayPause),
              ),
            ),
          ),

          if (_visible || !isPlaying)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.black45,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: true,
                      padding: EdgeInsets.zero,
                      colors: VideoProgressColors(
                        playedColor: Colors.tealAccent,
                        bufferedColor: Colors.tealAccent.shade100,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_current),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(_total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: .05.sh,
            right: 10,
            child: _MuteButton(controller: widget.controller),
          ),
        ],
      ),
    );
  }
}

class _MuteButton extends StatefulWidget {
  final VideoPlayerController controller;

  const _MuteButton({required this.controller});

  @override
  State<_MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<_MuteButton> {
  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      widget.controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isMuted ? Icons.volume_off : Icons.volume_up,
        color: Colors.white,
      ),
      onPressed: _toggleMute,
    );
  }
}

final Map<String, Future<Uint8List?>> _globalThumbnailCache = {};

class GalleryMediaItem extends StatefulWidget {
  final String url;
  final VoidCallback onTap;

  const GalleryMediaItem({super.key, required this.url, required this.onTap});

  @override
  State<GalleryMediaItem> createState() => _GalleryMediaItemState();
}

class _GalleryMediaItemState extends State<GalleryMediaItem> {
  Future<Uint8List?>? _thumbFuture;

  bool _isVideo(String url) =>
      url.toLowerCase().contains('.mp4') || url.toLowerCase().contains("video");

  bool get isVideo => _isVideo(widget.url);

  @override
  void initState() {
    super.initState();
    if (isVideo) {
      _thumbFuture = _globalThumbnailCache[widget.url];
      if (_thumbFuture == null) {
        _thumbFuture = generateVideoThumbnail(widget.url);
        _globalThumbnailCache[widget.url] = _thumbFuture!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child:
            isVideo
                ? FutureBuilder<Uint8List?>(
                  future: _thumbFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(color: Colors.black12);
                    }
                    return SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.memory(
                              snapshot.data!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Symbols.play_circle_rounded,
                              size: 40,
                              color: Colors.white,
                              fill: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
                : CachedNetworkImage(imageUrl: widget.url, fit: BoxFit.cover),
      ),
    );
  }
}
