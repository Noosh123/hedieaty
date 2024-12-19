import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageService {
  static const String _apiKey = '79288a438d0cc6b34874b752880cead7';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Uploads an image file to ImgBB and returns the URL of the uploaded image.
  /// [imagePath]: The local path of the image file.
  /// Returns: A string containing the URL of the uploaded image.
  Future<String?> uploadImage(String imagePath) async {
    try {
      // Read the image file and encode it to base64
      final imageBytes = File(imagePath).readAsBytesSync();
      final base64Image = base64Encode(imageBytes);

      // Prepare the request URL
      final requestUrl = '$_uploadUrl?key=$_apiKey';

      // Make the POST request to upload the image
      final response = await http.post(
        Uri.parse(requestUrl),
        body: {'image': base64Image},
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return responseBody['data']['url']; // Return the image URL
        } else {
          throw Exception('Image upload failed: ${responseBody['status']}');
        }
      } else {
        throw Exception('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
