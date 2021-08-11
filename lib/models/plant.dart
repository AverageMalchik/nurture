class PlantReference {
  final String cover;
  final String name;
  final int stock;
  final int pricing;
  final String id;
  PlantReference(
      {required this.cover,
      required this.name,
      required this.stock,
      required this.pricing,
      required this.id});

  factory PlantReference.fromMap(Map<String, dynamic> data) {
    final String cover = data['1'];
    final String name = data['name'];
    final int stock = data['stock'];
    final int pricing = data['pricing'];
    final String id = data['id'];
    return PlantReference(
        cover: cover, name: name, stock: stock, pricing: pricing, id: id);
  }
}
