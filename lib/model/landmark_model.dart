enum LandmarkCategory {
  quartier,
  marche,
  mosquee,
  hopital,
  gare,
  ecole,
  hotel,
  restaurant,
  banque,
  autre,
}

class LandmarkModel {
  final String id;
  final String nameFr;
  final String nameEn;
  final LandmarkCategory category;
  final double lat;
  final double lng;
  final bool isPopular;

  const LandmarkModel({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.category,
    required this.lat,
    required this.lng,
    this.isPopular = false,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    return LandmarkModel(
      id: json['id'] as String? ?? '',
      nameFr: json['name_fr'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      category: _parseCategory(json['category'] as String?),
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  static LandmarkCategory _parseCategory(String? cat) {
    switch (cat) {
      case 'quartier':
        return LandmarkCategory.quartier;
      case 'marche':
        return LandmarkCategory.marche;
      case 'mosquee':
        return LandmarkCategory.mosquee;
      case 'hopital':
        return LandmarkCategory.hopital;
      case 'gare':
        return LandmarkCategory.gare;
      case 'ecole':
        return LandmarkCategory.ecole;
      case 'hotel':
        return LandmarkCategory.hotel;
      case 'restaurant':
        return LandmarkCategory.restaurant;
      case 'banque':
        return LandmarkCategory.banque;
      default:
        return LandmarkCategory.autre;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_fr': nameFr,
      'name_en': nameEn,
      'category': category.name,
      'lat': lat,
      'lng': lng,
      'is_popular': isPopular,
    };
  }
}
