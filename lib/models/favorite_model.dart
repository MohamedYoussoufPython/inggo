import 'package:flutter/material.dart';

class FavoriteModel {
  final int id;
  final String name;
  final String address;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const FavoriteModel({
    required this.id,
    required this.name,
    required this.address,
    this.icon = Icons.place,
    this.bgColor = const Color(0xFFF5F7FA),
    this.iconColor = const Color(0xFF121212),
  });
}
