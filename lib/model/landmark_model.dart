import 'package:freezed_annotation/freezed_annotation.dart';

part 'landmark_model.freezed.dart';
part 'landmark_model.g.dart';

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

@freezed
class LandmarkModel with _$LandmarkModel {
  const factory LandmarkModel({
    required String id,
    required String nameFr,
    required String nameEn,
    required LandmarkCategory category,
    required double lat,
    required double lng,
    @Default(false) bool isPopular,
  }) = _LandmarkModel;

  factory LandmarkModel.fromJson(Map<String, dynamic> json) =>
      _$LandmarkModelFromJson(json);
}
