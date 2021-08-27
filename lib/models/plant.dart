class PlantReference {
  final String cover;
  final String secondary;
  final String description;
  final String category;
  final String name;
  final int stock;
  final int pricing;
  final String id;
  final String care;
  final String water;
  final String place;
  PlantReference(
      {required this.care,
      required this.cover,
      required this.secondary,
      required this.category,
      required this.description,
      required this.place,
      required this.water,
      required this.name,
      required this.stock,
      required this.pricing,
      required this.id});

  factory PlantReference.fromMap(Map<String, dynamic> data) {
    final String cover = data['1'];
    final String secondary = data['2'];
    final String category = data['category'];
    final String description = data['description'];
    final String place = data['place'];
    final String water = data['water'];
    final String care = data['care'];
    final String name = data['name'];
    final int stock = data['stock'];
    final int pricing = data['pricing'];
    final String id = data['id'];
    return PlantReference(
        care: care,
        cover: cover,
        secondary: secondary,
        category: category,
        description: description,
        place: place,
        water: water,
        name: name,
        stock: stock,
        pricing: pricing,
        id: id);
  }
}

class PlantLite {
  final PlantReference plant;
  final int count;
  PlantLite({required this.plant, required this.count});
}

class MyPlantreference {
  final PlantReference plant;
  final int count;
  final String time;
  final String last;
  final String purchase;
  MyPlantreference(
      {required this.last,
      required this.count,
      required this.plant,
      required this.purchase,
      required this.time});
  factory MyPlantreference.fromMap(Map<String, dynamic> data) {
    final int count = data['count'];
    final PlantReference plant = data['plant'];
    final String purchase = data['purchase'];
    final String time = data['water'];
    final String last = data['last'];
    return MyPlantreference(
        count: count, plant: plant, purchase: purchase, time: time, last: last);
  }
}
