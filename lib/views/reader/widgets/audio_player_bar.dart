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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                          thumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          trackHeight: 4,
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
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmt(pos),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _fmt(dur),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
          const SizedBox(height: 12),
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
                  const SizedBox(width: 24),
                  // Play / Pause
                  GestureDetector(
                    onTap: playing ? audioService.pause : audioService.play,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
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
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: AppColors.primary, size: 22),
          onPressed: onTap,
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(),
        ),
      );

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
