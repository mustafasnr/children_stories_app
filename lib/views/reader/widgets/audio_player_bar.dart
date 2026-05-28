import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/core/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerBar extends StatelessWidget {
  final AudioService audioService;

  const AudioPlayerBar({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seek bar
          StreamBuilder<Duration?>(
            stream: audioService.durationStream,
            builder: (context, durSnap) {
              final dur = durSnap.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, posSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final maxMs = dur.inMilliseconds.toDouble();
                  final posMs = pos.inMilliseconds.toDouble().clamp(
                    0.0,
                    maxMs > 0 ? maxMs : 1.0,
                  );
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          thumbColor: Colors.white,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.3,
                          ),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          trackHeight: 3,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: posMs,
                          max: maxMs > 0 ? maxMs : 1,
                          onChanged: (v) => audioService.seek(
                            Duration(milliseconds: v.toInt()),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmt(pos),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              _fmt(dur),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Controls
          StreamBuilder<PlayerState>(
            stream: audioService.playerStateStream,
            builder: (context, snap) {
              final playing = snap.data?.playing ?? false;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rewind 10s
                  _ctrlBtn(
                    icon: Icons.replay_10_rounded,
                    onTap: () => audioService.rewind(),
                  ),
                  const SizedBox(width: 8),
                  // Play / Pause
                  GestureDetector(
                    onTap: playing ? audioService.pause : audioService.play,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Forward 10s
                  _ctrlBtn(
                    icon: Icons.forward_10_rounded,
                    onTap: () => audioService.fastForward(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn({required IconData icon, required VoidCallback onTap}) =>
      IconButton(
        icon: Icon(icon, color: Colors.white, size: 26),
        onPressed: onTap,
        padding: const EdgeInsets.all(8),
      );

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
