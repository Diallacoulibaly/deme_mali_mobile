import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '/../../../models/preuve_distribution.dart';

const String baseUrlFichiers = 'http://localhost:8080';

class PreuveDistributionWidget extends StatelessWidget {
  const PreuveDistributionWidget({
    super.key,
    required this.preuve,
  });

  final PreuveDistribution preuve;

  @override
  Widget build(BuildContext context) {
    final url = _urlComplete(preuve.urlFichier);
    final type = (preuve.typeMedia ?? '').toLowerCase();
    final estVideo = type.contains('video') ||
        type.contains('vidéo') ||
        (url != null &&
            (url.toLowerCase().endsWith('.mp4') ||
                url.toLowerCase().endsWith('.mov') ||
                url.toLowerCase().endsWith('.webm')));

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: url == null
          ? null
          : () {
              showDialog<void>(
                context: context,
                builder: (_) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: estVideo
                        ? _LecteurVideo(url: url)
                        : InteractiveViewer(
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const _ErreurMedia(),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              );
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 100,
              width: double.infinity,
              color: const Color(0xFFF0EEE8),
              child: url == null
                  ? const _ErreurMedia()
                  : estVideo
                      ? const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            size: 42,
                            color: Color(0xFF0F7A4B),
                          ),
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _ErreurMedia(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            estVideo ? 'Vidéo de preuve' : 'Image de preuve',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  String? _urlComplete(String? valeur) {
    final chemin = valeur?.trim();
    if (chemin == null || chemin.isEmpty) return null;
    if (chemin.startsWith('http://') || chemin.startsWith('https://')) {
      return chemin;
    }
    final cheminNormalise = chemin.startsWith('/') ? chemin : '/$chemin';
    return '$baseUrlFichiers$cheminNormalise';
  }
}

class _ErreurMedia extends StatelessWidget {
  const _ErreurMedia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: 32,
        color: Color(0xFF888888),
      ),
    );
  }
}

class _LecteurVideo extends StatefulWidget {
  const _LecteurVideo({required this.url});

  final String url;

  @override
  State<_LecteurVideo> createState() => _LecteurVideoState();
}

class _LecteurVideoState extends State<_LecteurVideo> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialisation;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initialisation = _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialisation,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const SizedBox(
            height: 220,
            child: Center(child: Text('Impossible de lire cette vidéo.')),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              icon: Icon(
                _controller.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                size: 42,
                color: const Color(0xFF0F7A4B),
              ),
            ),
          ],
        );
      },
    );
  }
}
