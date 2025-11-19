class Property {
  final String imagePath;
  final String price;
  final String name;
  final String location;

  Property({
    required this.imagePath,
    required this.price,
    required this.name,
    required this.location,
  });
}

List<Property> featuredProperties = [
  Property(
    imagePath: 'assets/logo1.jpg',
    price: ' 1.5cr /-',
    name: 'Sampura Villa',
    location: 'Ahmedabad',
  ),
  Property(
    imagePath: 'assets/logo1.jpg',
    price: ' 1.5cr /-',
    name: 'Sampura Villa',
    location: 'Ahmedabad',
  ),
];
