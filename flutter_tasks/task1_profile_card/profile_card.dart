import 'package:flutter/material.dart';

/// A small data holder for one stat shown in the ProfileCard
/// (e.g. Posts / Followers / Following).
class ProfileStat {
  final String label;
  final String value;

  const ProfileStat({required this.label, required this.value});
}

/// Reusable profile card widget.
///
/// Approach notes:
/// - We never hardcode pixel widths for the stats row; instead each stat is
///   wrapped in an `Expanded` so the row divides available width evenly and
///   never overflows, whether the card is placed on a 360dp phone or an
///   800dp tablet.
/// - The overall card width is NOT fixed either — it fills whatever width
///   its parent gives it (via `double.infinity` inside a `Card`), so the
///   caller controls sizing (e.g. wrap in a `SizedBox`/`ConstrainedBox` on
///   a tablet to cap max width if desired).
/// - All colors come from `Theme.of(context)` (colorScheme / textTheme) so
///   the widget automatically adapts to light/dark mode with no manual
///   branching.
/// - The avatar uses `Image.network` with `loadingBuilder` (shows a
///   `CircularProgressIndicator` while bytes are streaming in) and
///   `errorBuilder` (falls back to a person icon if the URL 404s or the
///   device is offline).
class ProfileCard extends StatelessWidget {
  final String name;
  final String designation;
  final String avatarUrl;
  final List<ProfileStat> stats;

  const ProfileCard({
    super.key,
    required this.name,
    required this.designation,
    required this.avatarUrl,
    required this.stats,
  }) : assert(stats.length == 3, 'ProfileCard expects exactly 3 stats');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(avatarUrl: avatarUrl, colorScheme: colorScheme),
            const SizedBox(height: 12),
            // Name / designation use Theme text styles, not hardcoded fonts.
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              designation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
            // Stats row: Expanded ensures even spacing regardless of screen
            // width (360dp phone vs 800dp tablet) with zero fixed widths.
            Row(
              children: [
                for (final stat in stats)
                  Expanded(
                    child: _StatColumn(stat: stat, theme: theme),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String avatarUrl;
  final ColorScheme colorScheme;

  const _Avatar({required this.avatarUrl, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 72,
        height: 72,
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          // Loading placeholder while bytes stream in.
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
          // Fallback icon if the image fails to load (bad URL / offline).
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: Icon(
                Icons.person,
                size: 36,
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final ProfileStat stat;
  final ThemeData theme;

  const _StatColumn({required this.stat, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat.value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
