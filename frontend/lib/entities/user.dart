class User {
  final String username;
  final String id;
  String country;
  String? city;
  Set<String> favArtwork = {};
  Set<String> favGallery = {};
  Set<String> favArtist = {};
  bool isVIP;
  bool auctions;
  bool fairs;
  
  User({
    required this.username,
    required this.id,
    required this.country,
    required this.isVIP,
    required this.auctions,
    required this.fairs
  });
}