import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaveTile {
  int rotation; // 0, 1, 2, 3 (each is 90 deg)
  final int targetRotation;
  final String type; // 'line', 'corner', 'curve'
  final int colorIndex;

  WaveTile({
    required this.rotation,
    required this.targetRotation,
    required this.type,
    this.colorIndex = 0,
  });

  bool get isAligned => rotation % 4 == targetRotation % 4;

  Map<String, dynamic> toJson() => {
        'rotation': rotation,
        'targetRotation': targetRotation,
        'type': type,
        'colorIndex': colorIndex,
      };

  static WaveTile fromJson(Map<String, dynamic> j) => WaveTile(
        rotation: (j['rotation'] as num?)?.toInt() ?? 0,
        targetRotation: (j['targetRotation'] as num?)?.toInt() ?? 0,
        type: (j['type'] ?? 'line').toString(),
        colorIndex: (j['colorIndex'] as num?)?.toInt() ?? 0,
      );
}

class WaveLevel {
  final String id;
  final String chapterId;
  final String name;
  final int size; // 3 or 4
  final List<WaveTile> defaultTiles;

  WaveLevel({
    required this.id,
    required this.chapterId,
    required this.name,
    required this.size,
    required this.defaultTiles,
  });
}

class WaveStore extends ChangeNotifier {
  static const _scoresKey = 'wavefold_progress_v1';

  final List<WaveLevel> _levels = [];
  final Map<String, int> _scores = {}; // levelId -> stars (1-3)
  bool _ready = false;

  WaveLevel? _activeLevel;
  List<WaveTile> _currentTiles = [];
  int _moves = 0;

  bool get ready => _ready;
  List<WaveLevel> get levels => List.unmodifiable(_levels);
  Map<String, int> get scores => Map.unmodifiable(_scores);
  WaveLevel? get activeLevel => _activeLevel;
  List<WaveTile> get currentTiles => List.unmodifiable(_currentTiles);
  int get moves => _moves;

  int get totalCompleted => _scores.length;

  Future<void> load() async {
    _generateAllLevels();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_scoresKey);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _scores.clear();
        for (final entry in map.entries) {
          _scores[entry.key] = (entry.value as num).toInt();
        }
      }
    } catch (_) {}

    if (_scores.isEmpty) {
      _scores['lvl_1'] = 3;
      _scores['lvl_2'] = 3;
    }

    startLevel(_levels.first);

    _ready = true;
    notifyListeners();
  }

  void _generateAllLevels() {
    _levels.clear();
    final chapters = [
      (id: 'c1', name: 'Спокойствие', size: 3),
      (id: 'c2', name: 'Течение', size: 3),
      (id: 'c3', name: 'Гармония', size: 4),
      (id: 'c4', name: 'Мастерство', size: 4),
    ];

    int globalIndex = 1;
    for (final ch in chapters) {
      for (int i = 1; i <= 6; i++) {
        final size = ch.size;
        final count = size * size;
        final tiles = List.generate(count, (idx) {
          final target = (idx + i) % 4;
          final startRot = (target + (idx % 3 == 0 ? 1 : 2)) % 4;
          return WaveTile(
            rotation: startRot,
            targetRotation: target,
            type: idx % 2 == 0 ? 'curve' : 'line',
            colorIndex: idx % 3,
          );
        });

        _levels.add(WaveLevel(
          id: 'lvl_$globalIndex',
          chapterId: ch.id,
          name: '${ch.name} · Узор $i',
          size: size,
          defaultTiles: tiles,
        ));
        globalIndex++;
      }
    }
  }

  void startLevel(WaveLevel level) {
    _activeLevel = level;
    _currentTiles = level.defaultTiles
        .map((t) => WaveTile(
              rotation: t.rotation,
              targetRotation: t.targetRotation,
              type: t.type,
              colorIndex: t.colorIndex,
            ))
        .toList();
    _moves = 0;
    notifyListeners();
  }

  void rotateTile(int index) {
    if (index >= 0 && index < _currentTiles.length) {
      _currentTiles[index].rotation = (_currentTiles[index].rotation + 1) % 4;
      _moves++;
      notifyListeners();
    }
  }

  bool isSolved() {
    for (final t in _currentTiles) {
      if (!t.isAligned) return false;
    }
    return true;
  }

  Future<void> completeCurrentLevel(int stars) async {
    if (_activeLevel == null) return;
    final currentBest = _scores[_activeLevel!.id] ?? 0;
    if (stars > currentBest) {
      _scores[_activeLevel!.id] = stars;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_scoresKey, jsonEncode(_scores));
      } catch (_) {}
    }
  }

  void resetCurrentLevel() {
    if (_activeLevel != null) {
      startLevel(_activeLevel!);
    }
  }

  Future<void> resetAll() async {
    _scores.clear();
    _scores['lvl_1'] = 3;
    startLevel(_levels.first);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scoresKey);
    } catch (_) {}
  }
}

class WaveScope extends InheritedNotifier<WaveStore> {
  const WaveScope({super.key, required WaveStore store, required super.child})
      : super(notifier: store);

  static WaveStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WaveScope>();
    assert(scope != null, 'WaveScope not found');
    return scope!.notifier!;
  }
}
