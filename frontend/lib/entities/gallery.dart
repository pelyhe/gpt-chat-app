class Gallery {
  final String id;
  final String companyName;
  final String companyTaxNumber;
  final String contactEmail;
  final String contactName;
  final String contactPhone;
  final String name;
  final String city;
  final String zipCode;
  final String address;
  final String country;
  final String priceRange;

  Gallery(
      {required this.id,
      required this.companyName,
      required this.companyTaxNumber,
      required this.contactEmail,
      required this.contactName,
      required this.contactPhone,
      required this.name,
      required this.city,
      required this.zipCode,
      required this.address,
      required this.country,
      required this.priceRange});
}
