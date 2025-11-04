class OperationManualModel {
  final String id;
  final String title;
  final String category;
  final String shortDescription;
  final List<ContentBlock> content;

  OperationManualModel({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.content,
  });

  factory OperationManualModel.fromJson(Map<String, dynamic> json) {
    return OperationManualModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      content: (json['content'] as List<dynamic>?)
          ?.map((item) => ContentBlock.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'shortDescription': shortDescription,
      'content': content.map((item) => item.toJson()).toList(),
    };
  }
}

abstract class ContentBlock {
  final String type;

  ContentBlock({required this.type});

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'text':
        return TextBlock.fromJson(json);
      case 'heading':
        return HeadingBlock.fromJson(json);
      case 'image':
        return ImageBlock.fromJson(json);
      case 'list':
        return ListBlock.fromJson(json);
      case 'numbered_list':
        return NumberedListBlock.fromJson(json);
      case 'warning':
        return WarningBlock.fromJson(json);
      case 'info':
        return InfoBlock.fromJson(json);
      case 'gallery':
        return GalleryBlock.fromJson(json);
      case 'table':
        return TableBlock.fromJson(json);
      case 'quote':
        return QuoteBlock.fromJson(json);
      case 'divider':
        return DividerBlock.fromJson(json);
      case 'video':
        return VideoBlock.fromJson(json);
      default:
        return TextBlock(text: 'Unknown block type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

class TextBlock extends ContentBlock {
  final String text;

  TextBlock({required this.text}) : super(type: 'text');

  factory TextBlock.fromJson(Map<String, dynamic> json) {
    return TextBlock(text: json['data'] ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'data': text};
  }
}

class HeadingBlock extends ContentBlock {
  final String text;

  HeadingBlock({required this.text}) : super(type: 'heading');

  factory HeadingBlock.fromJson(Map<String, dynamic> json) {
    return HeadingBlock(text: json['data'] ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'data': text};
  }
}

class ImageBlock extends ContentBlock {
  final String path;
  final String? description;
  final String? caption;

  ImageBlock({
    required this.path,
    this.description,
    this.caption,
  }) : super(type: 'image');

  factory ImageBlock.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ImageBlock(
      path: data['path'] ?? '',
      description: data['description'],
      caption: data['caption'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {
        'path': path,
        'description': description,
        'caption': caption,
      }
    };
  }
}

class ListBlock extends ContentBlock {
  final String? title;
  final List<String> items;

  ListBlock({this.title, required this.items}) : super(type: 'list');

  factory ListBlock.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ListBlock(
      title: data['title'],
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'title': title, 'items': items}
    };
  }
}

class NumberedListBlock extends ContentBlock {
  final String? title;
  final List<String> items;

  NumberedListBlock({this.title, required this.items})
      : super(type: 'numbered_list');

  factory NumberedListBlock.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return NumberedListBlock(
      title: data['title'],
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'title': title, 'items': items}
    };
  }
}

class WarningBlock extends ContentBlock {
  final String text;

  WarningBlock({required this.text}) : super(type: 'warning');

  factory WarningBlock.fromJson(Map<String, dynamic> json) {
    return WarningBlock(text: json['data'] ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'data': text};
  }
}

class InfoBlock extends ContentBlock {
  final String text;

  InfoBlock({required this.text}) : super(type: 'info');

  factory InfoBlock.fromJson(Map<String, dynamic> json) {
    return InfoBlock(text: json['data'] ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'data': text};
  }
}

class GalleryBlock extends ContentBlock {
  final String? title;
  final List<GalleryImage> images;

  GalleryBlock({this.title, required this.images}) : super(type: 'gallery');

  factory GalleryBlock.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return GalleryBlock(
      title: data['title'],
      images: (data['images'] as List<dynamic>?)
          ?.map((item) => GalleryImage.fromJson(item))
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {
        'title': title,
        'images': images.map((img) => img.toJson()).toList()
      }
    };
  }
}

class GalleryImage {
  final String path;
  final String? description;

  GalleryImage({required this.path, this.description});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      path: json['path'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'path': path, 'description': description};
  }
}

class TableBlock extends ContentBlock {
  final List<String> headers;
  final List<List<String>> rows;

  TableBlock({required this.headers, required this.rows})
      : super(type: 'table');

  factory TableBlock.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TableBlock(
      headers: (data['headers'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
      rows: (data['rows'] as List<dynamic>?)
          ?.map((row) => (row as List<dynamic>)
          .map((cell) => cell.toString())
          .toList())
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'headers': headers, 'rows': rows}
    };
  }
}

class QuoteBlock extends ContentBlock {
  final String text;

  QuoteBlock({required this.text}) : super(type: 'quote');

  factory QuoteBlock.fromJson(Map<String, dynamic> json) {
    return QuoteBlock(text: json['data'] ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'data': text};
  }
}

class DividerBlock extends ContentBlock {
  DividerBlock() : super(type: 'divider');

  factory DividerBlock.fromJson(Map<String, dynamic> json) {
    return DividerBlock();
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type};
  }
}

class VideoBlock extends ContentBlock {
  final String thumbnail;
  final String title;
  final String? duration;

  VideoBlock({
    required this.thumbnail,
    required this.title,
    this.duration,
  }) : super(type: 'video');

  factory VideoBlock.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return VideoBlock(
      thumbnail: data['thumbnail'] ?? '',
      title: data['title'] ?? '',
      duration: data['duration'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'thumbnail': thumbnail, 'title': title, 'duration': duration}
    };
  }
}