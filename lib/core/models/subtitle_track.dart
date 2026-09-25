class SubtitleTrack {
  const SubtitleTrack({
    required this.index,
    required this.codec,
    this.language,
    this.title,
    this.isDefault = false,
    this.isForced = false,
    this.isText = false,
  });

  final int index;
  final String codec;
  final String? language;
  final String? title;
  final bool isDefault;
  final bool isForced;
  final bool isText;

  String get codecLabel {
    switch (codec) {
      case 'subrip':
        return 'SRT';
      case 'ass':
        return 'ASS';
      case 'ssa':
        return 'SSA';
      case 'webvtt':
        return 'WebVTT';
      case 'mov_text':
        return 'MOV';
      case 'hdmv_pgs_subtitle':
        return 'PGS';
      case 'dvd_subtitle':
        return 'VobSub';
      default:
        return codec.toUpperCase();
    }
  }

  String get summary {
    final bits = <String>[
      'Track $index',
      if (language != null && language!.isNotEmpty) language!,
      codecLabel,
      if (title != null && title!.isNotEmpty) title!,
      if (isDefault) 'Default',
      if (isForced) 'Forced',
      if (!isText) 'Remove only',
    ];
    return bits.join(' · ');
  }
}

class SubtitleAddition {
  const SubtitleAddition({
    required this.path,
    this.language = '',
    this.title = '',
    this.isDefault = false,
  });

  final String path;
  final String language;
  final String title;
  final bool isDefault;

  String get extension {
    final dot = path.lastIndexOf('.');
    if (dot < 0) {
      return '';
    }
    return path.substring(dot).toLowerCase();
  }

  bool get isTextSubtitle {
    return const {'.srt', '.ass', '.ssa', '.vtt'}.contains(extension);
  }

  SubtitleAddition copyWith({
    String? language,
    String? title,
    bool? isDefault,
  }) {
    return SubtitleAddition(
      path: path,
      language: language ?? this.language,
      title: title ?? this.title,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'language': language,
      'title': title,
      'isDefault': isDefault,
    };
  }

  factory SubtitleAddition.fromJson(Map<String, dynamic> json) {
    return SubtitleAddition(
      path: json['path'] as String? ?? '',
      language: json['language'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

const subtitleExtensions = <String>{'srt', 'ass', 'ssa', 'vtt'};

bool isSubtitlePath(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) {
    return false;
  }
  return subtitleExtensions.contains(path.substring(dot + 1).toLowerCase());
}

class SubtitleEdit {
  const SubtitleEdit({
    required this.keepIndexes,
    this.additions = const [],
  });

  final List<int> keepIndexes;
  final List<SubtitleAddition> additions;

  SubtitleEdit copyWith({
    List<int>? keepIndexes,
    List<SubtitleAddition>? additions,
  }) {
    return SubtitleEdit(
      keepIndexes: keepIndexes ?? this.keepIndexes,
      additions: additions ?? this.additions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keepIndexes': keepIndexes,
      'additions': additions.map((item) => item.toJson()).toList(),
    };
  }

  factory SubtitleEdit.fromJson(Map<String, dynamic> json) {
    return SubtitleEdit(
      keepIndexes: (json['keepIndexes'] as List<dynamic>? ?? const [])
          .map((item) => (item as num).toInt())
          .toList(growable: false),
      additions: (json['additions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubtitleAddition.fromJson)
          .toList(growable: false),
    );
  }
}
