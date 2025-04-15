class FileUploadResponse {
  final String? filename;
  final int? size;
  final String fileUrl;
  FileUploadResponse({
    this.filename,
    this.size,
    required this.fileUrl,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      filename: json['filename'] as String?,
      size: json['size'] as int?, 
      fileUrl: json['fileUrl'] as String, 
    );
  }
}
