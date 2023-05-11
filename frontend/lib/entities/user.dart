class User {
  final String username;
  final String id;
  String country;
  String? city;
  // TODO: store these as list of ObjectIds pointing to artwork, gallery and artist entities
  String favArtwork;
  String favGallery;
  String favArtist;
  bool isVIP;
  bool auctions;
  bool fairs;
  
  User({
    required this.username,
    required this.id,
    required this.country,
    required this.isVIP,
    required this.auctions,
    required this.fairs,
    this.city,
    this.favArtist = "",
    this.favArtwork = "",
    this.favGallery = ""
  });
}