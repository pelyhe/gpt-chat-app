import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../entities/gallery.dart';

class GalleryService {
  Future<List<Gallery>?> getGalleries() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['CHAT_API_URL']}/gallery'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode != 200) {
        return null;
      } else {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Gallery> result = [];
        Gallery gallery;
        for (var i = 0; i < jsonData.length; i++) {
          gallery = Gallery(
            id: jsonData[i]['_id'],
            companyName: jsonData[i]['companyName'],
            companyTaxNumber: jsonData[i]['companyTaxNumber'],
            contactEmail: jsonData[i]['contactEmail'],
            contactName: jsonData[i]['contactName'],
            contactPhone: jsonData[i]['contactPhone'],
            name: jsonData[i]['name'],
            city: jsonData[i]['city'],
            zipCode: jsonData[i]['zipCode'],
            address: jsonData[i]['address'],
            country: jsonData[i]['country'],
            priceRange: jsonData[i]['priceRange'],
          );
          result.add(gallery);
        }
        return result;
      }
    } catch (error) {
      return null;
    }
  }
}
