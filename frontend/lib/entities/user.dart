class User {
  final String username;
  final String id;
  String country;
  String? city;
  //TODO fav artworks... are stored as an array, this version only stores the quiz results
  String? favArtwork;
  String? favGallery;
  String? favArtist;
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
    //favokat beírni
  });
}