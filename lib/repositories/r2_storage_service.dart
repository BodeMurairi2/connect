import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class R2StorageService {
  static const _accessKey = String.fromEnvironment('R2_ACCESS_KEY');
  static const _secretKey = String.fromEnvironment('R2_SECRET_KEY');
  static const _bucket = String.fromEnvironment('R2_BUCKET');
  static const _endpoint = String.fromEnvironment('R2_ENDPOINT');
  static const _publicUrl = String.fromEnvironment('R2_PUBLIC_URL');
  static const _region = 'auto';

  Future<String> uploadBytes({
    required Uint8List bytes,
    required String objectKey,
    required String fileName,
  }) async {
    return _upload(bytes: bytes, objectKey: objectKey, contentType: _contentType(fileName));
  }

  Future<String> uploadFile(File file, String objectKey) async {
    final bytes = await file.readAsBytes();
    return _upload(bytes: bytes, objectKey: objectKey, contentType: _contentType(file.path));
  }

  Future<String> _upload({
    required Uint8List bytes,
    required String objectKey,
    required String contentType,
  }) async {
    final now = DateTime.now().toUtc();
    final dateStr = _formatDate(now);
    final datetimeStr = _formatDatetime(now);
    final payloadHash = sha256.convert(bytes).toString();
    final host = Uri.parse(_endpoint).host;
    final path = '/$_bucket/$objectKey';

    final canonicalHeaders =
        'host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$datetimeStr\n';
    const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';

    final canonicalUri = path.split('/').map((s) => Uri.encodeComponent(s)).join('/');
    final canonicalRequest =
        'PUT\n$canonicalUri\n\n$canonicalHeaders\n$signedHeaders\n$payloadHash';

    final credentialScope = '$dateStr/$_region/s3/aws4_request';
    final stringToSign =
        'AWS4-HMAC-SHA256\n$datetimeStr\n$credentialScope\n'
        '${sha256.convert(utf8.encode(canonicalRequest))}';

    final signingKey = _signingKey(_secretKey, dateStr);
    final signature =
        Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    final authorization =
        'AWS4-HMAC-SHA256 Credential=$_accessKey/$credentialScope, '
        'SignedHeaders=$signedHeaders, Signature=$signature';

    final response = await http.put(
      Uri.parse('$_endpoint$path'),
      headers: {
        'Authorization': authorization,
        'x-amz-date': datetimeStr,
        'x-amz-content-sha256': payloadHash,
        'Content-Type': contentType,
        'Content-Length': bytes.length.toString(),
      },
      body: bytes,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('R2 upload failed: ${response.statusCode} ${response.body}');
    }

    return '$_publicUrl/$objectKey';
  }

  List<int> _signingKey(String secret, String date) {
    final kDate = Hmac(sha256, utf8.encode('AWS4$secret')).convert(utf8.encode(date)).bytes;
    final kRegion = Hmac(sha256, kDate).convert(utf8.encode(_region)).bytes;
    final kService = Hmac(sha256, kRegion).convert(utf8.encode('s3')).bytes;
    return Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';

  String _formatDatetime(DateTime dt) =>
      '${_formatDate(dt)}T'
      '${dt.hour.toString().padLeft(2, '0')}'
      '${dt.minute.toString().padLeft(2, '0')}'
      '${dt.second.toString().padLeft(2, '0')}Z';

  String _contentType(String path) {
    if (path.endsWith('.pdf')) return 'application/pdf';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    return 'application/octet-stream';
  }
}
