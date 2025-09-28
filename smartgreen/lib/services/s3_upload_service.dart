// lib/services/s3_upload_service.dart
// Upload manual para S3 usando Dio e assinatura AWS v4
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../aws_s3_config.dart';
import 'package:dio/io.dart';

class S3UploadService {
  static Future<
    String
  >
  uploadFile({
    required File file,
    required String filename,
    String contentType =
        'image/jpeg',
  }) async {
    final key =
        '$s3DestDir/$filename';
    final endpoint =
        'https://$s3Bucket.s3.$s3Region.amazonaws.com/$key';
    final now =
        DateTime.now().toUtc();
    final date = now
        .toIso8601String()
        .substring(
          0,
          10,
        )
        .replaceAll(
          '-',
          '',
        );
    final amzDate =
        now
            .toIso8601String()
            .replaceAll(
              '-',
              '',
            )
            .replaceAll(
              ':',
              '',
            )
            .split(
              '.',
            )
            .first +
        'Z';

    List<
      int
    >
    _sign(
      List<
        int
      >
      key,
      String msg,
    ) =>
        Hmac(
              sha256,
              key,
            )
            .convert(
              utf8.encode(
                msg,
              ),
            )
            .bytes;
    final kDate = _sign(
      utf8.encode(
        'AWS4$s3SecretKey',
      ),
      date,
    );
    final kRegion = _sign(
      kDate,
      s3Region,
    );
    final kService = _sign(
      kRegion,
      's3',
    );
    final kSigning = _sign(
      kService,
      'aws4_request',
    );

    final payloadHash =
        sha256
            .convert(
              await file.readAsBytes(),
            )
            .toString();
    final credentialScope =
        '$date/$s3Region/s3/aws4_request';
    final canonicalHeaders =
        'content-type:$contentType\nhost:$s3Bucket.s3.$s3Region.amazonaws.com\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';
    final signedHeaders =
        'content-type;host;x-amz-content-sha256;x-amz-date';
    final canonicalRequest = [
      'PUT',
      '/$key',
      '',
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join(
      '\n',
    );

    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256
          .convert(
            utf8.encode(
              canonicalRequest,
            ),
          )
          .toString(),
    ].join(
      '\n',
    );

    final signature =
        Hmac(
              sha256,
              kSigning,
            )
            .convert(
              utf8.encode(
                stringToSign,
              ),
            )
            .toString();

    final authorization =
        'AWS4-HMAC-SHA256 Credential=$s3AccessKey/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    final headers = {
      'Content-Type':
          contentType,
      'x-amz-content-sha256':
          payloadHash,
      'x-amz-date':
          amzDate,
      'Authorization':
          authorization,
    };

    final dio =
        Dio();
    final fileBytes =
        await file.readAsBytes();
    final response = await dio.put(
      endpoint,
      data:
          fileBytes,
      options: Options(
        headers:
            headers,
      ),
    );

    if (response.statusCode ==
        200) {
      return endpoint;
    } else {
      throw Exception(
        'Failed to upload to S3: \nStatus: \${response.statusCode} \nBody: \${response.data}',
      );
    }
  }
}
