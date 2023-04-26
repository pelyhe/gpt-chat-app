class User {
  final String username;
  final String id;
  String? country;
  String? city;
  String? favArtwork;
  String? favGallery;
  String? favArtist;
  String? job;
  bool? auctions;
  bool? fairs;
  
  User({
    required this.username,
    required this.id
  });
}