import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import 'wave_store.dart';

/// Экран 1. Главы медитативных узоров
class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key, required this.onOpenBoard});

  final VoidCallback onOpenBoard;

  @override
  Widget build(BuildContext context) {
    final store = WaveScope.of(context);
    final levels = store.levels;
    final scores = store.scores;

    final chapters = [
      (id: 'c1', name: 'Спокойствие', desc: 'Мягкие волны и базовые соединения', icon: Icons.spa_rounded),
      (id: 'c2', name: 'Течение', desc: 'Параллельные потоки и перекрёстки', icon: Icons.waves_rounded),
      (id: 'c3', name: 'Гармония', desc: 'Симметричные двухцветные контуры', icon: Icons.wb_twilight_rounded),
      (id: 'c4', name: 'Мастерство', desc: 'Сложные медитативные лабиринты', icon: Icons.auto_awesome_rounded),
    ];

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('WaveFold', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Медитативное складывание непрерывных волн', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 18),
            ...chapters.map((ch) {
              final chLevels = levels.where((l) => l.chapterId == ch.id).toList();
              final completedInCh = chLevels.where((l) => scores.containsKey(l.id)).length;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cEdge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cAccent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(ch.icon, color: cAccent, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ch.name, style: AppTheme.display(18)),
                              Text(ch.desc, style: AppTheme.text(12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                        Text('$completedInCh/${chLevels.length}', style: AppTheme.text(13, color: cAccent, weight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: chLevels.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, idx) {
                        final lvl = chLevels[idx];
                        final isDone = scores.containsKey(lvl.id);

                        return GestureDetector(
                          onTap: () {
                            store.startLevel(lvl);
                            onOpenBoard();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDone ? cAccent : cBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDone ? cAccent : cEdge),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  color: isDone ? Colors.white : AppTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Экран 2. Игровая доска волн
class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = WaveScope.of(context);
    final level = store.activeLevel;

    if (level == null) {
      return const Scaffold(
        backgroundColor: cBg,
        body: Center(child: Text('Выберите уровень в главах')),
      );
    }

    final size = level.size;
    final tiles = store.currentTiles;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(level.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.display(18)),
                      const SizedBox(height: 2),
                      Text('Вращайте сегменты, чтобы выровнять волну', style: AppTheme.text(12.5, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cEdge),
                  ),
                  child: Text(
                    'Ходы: ${store.moves}',
                    style: AppTheme.text(14, color: cAccent, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 320,
                height: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cEdge),
                  boxShadow: [
                    BoxShadow(
                      color: cAccent.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: size * size,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, idx) {
                    final tile = tiles.length > idx ? tiles[idx] : WaveTile(rotation: 0, targetRotation: 0, type: 'line');
                    return GestureDetector(
                      onTap: () async {
                        store.rotateTile(idx);
                        if (store.isSolved()) {
                          await store.completeCurrentLevel(3);
                          if (context.mounted) {
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: cSurface,
                                title: Text('Волна объединена! 🌊', style: AppTheme.display(20, color: cAccent)),
                                content: Text('Линии идеально совпали за ${store.moves} ходов.', style: AppTheme.text(14, color: cInk)),
                                actions: [
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: cAccent, foregroundColor: Colors.white),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Продолжить'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      child: AnimatedRotation(
                        turns: tile.rotation * 0.25,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          decoration: BoxDecoration(
                            color: tile.isAligned ? cAccent.withValues(alpha: 0.15) : cBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: tile.isAligned ? cAccent : cEdge, width: 1.5),
                          ),
                          child: CustomPaint(
                            painter: _WaveTilePainter(type: tile.type, isAligned: tile.isAligned),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: cEdge),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => store.resetCurrentLevel(),
                    icon: const Icon(Icons.restart_alt_rounded, size: 18, color: cInk),
                    label: Text('Сброс', style: AppTheme.text(14, color: cInk)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: cAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Подсказка: Каждый тап поворачивает сегмент волны на 90°.')),
                      );
                    },
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                    label: Text('Подсказка', style: AppTheme.text(14, color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveTilePainter extends CustomPainter {
  final String type;
  final bool isAligned;

  _WaveTilePainter({required this.type, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAligned ? cAccent : cAccent2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    if (type == 'line') {
      canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), paint);
    } else {
      // corner arc
      final path = Path();
      path.moveTo(w / 2, 0);
      path.quadraticBezierTo(w / 2, h / 2, w, h / 2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveTilePainter oldDelegate) =>
      oldDelegate.isAligned != isAligned || oldDelegate.type != type;
}

/// Экран 3. Коллекция открытых узоров
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = WaveScope.of(context);
    final totalCompleted = store.totalCompleted;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Коллекция узоров', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Гармоничные медитативные композиции', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: cEdge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.waves_rounded, color: cAccent, size: 28),
                        const SizedBox(height: 10),
                        Text('$totalCompleted / 24', style: AppTheme.display(24, color: cAccent)),
                        const SizedBox(height: 2),
                        Text('Узоров открыто', style: AppTheme.text(12.5, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: cEdge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.self_improvement_rounded, color: cAccent2, size: 28),
                        const SizedBox(height: 10),
                        Text('${(totalCompleted / 24 * 100).toInt()}%', style: AppTheme.display(24, color: cAccent2)),
                        const SizedBox(height: 2),
                        Text('Гармония потока', style: AppTheme.text(12.5, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 4. Настройки
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = WaveScope.of(context);

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Настройки', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('WaveFold v1.0.0', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.waves_outlined, color: cAccent),
                    title: Text('Всего уровней', style: AppTheme.text(15, color: cInk)),
                    trailing: Text('${store.levels.length}', style: AppTheme.text(15, color: cAccent, weight: FontWeight.w700)),
                  ),
                  const Divider(height: 1, color: cEdge),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent),
                    title: const Text('Сбросить прогресс узоров', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cSurface,
                          title: Text('Сбросить прогресс?', style: AppTheme.display(18)),
                          content: Text('Все завершённые уровни будут сброшены.', style: AppTheme.text(14, color: cInk)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Сбросить'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await store.resetAll();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
