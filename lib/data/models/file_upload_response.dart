class FileUploadResponse {
  final String filename;
  final int size;
  final String? downloadUrl;

  FileUploadResponse({
    required this.filename,
    required this.size,
    this.downloadUrl,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      filename: json['filename'],
      size: json['size'],
      downloadUrl: json['downloadUrl'],
    );
  }
}