class BackupModel {
  int? id;
  String filename;
  String createdAt; // ISO 8601 date string

  /// Constructor
  BackupModel({
    this.id,
    required this.filename,
    required this.createdAt,
  });

  /// Create BackupModel from Map (e.g., from SQLite query)
  factory BackupModel.fromMap(Map<String, dynamic> map) {
    return BackupModel(
      id: map['id'],
      filename: map['filename'],
      createdAt: map['created_at'],
    );
  }

  /// Convert BackupModel to Map (for SQLite insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'created_at': createdAt,
    };
  }

  /// Create a copy with updated fields
  BackupModel copyWith({
    int? id,
    String? filename,
    String? createdAt,
  }) {
    return BackupModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Debug-friendly string
  @override
  String toString() =>
      'BackupModel(id: $id, filename: $filename, createdAt: $createdAt)';
}
