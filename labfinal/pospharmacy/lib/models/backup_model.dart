class BackupModel {
  int? id;
  String filename;
  String createdAt; // ISO string

  BackupModel({this.id, required this.filename, required this.createdAt});

  factory BackupModel.fromMap(Map<String, dynamic> map) {
    return BackupModel(
      id: map['id'],
      filename: map['filename'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'created_at': createdAt,
    };
  }

  BackupModel copyWith({int? id, String? filename, String? createdAt}) {
    return BackupModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Backup(id: $id, filename: $filename, createdAt: $createdAt)';
}
