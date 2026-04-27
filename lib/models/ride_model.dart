class RideModel {
  final int id;
  final String date;
  final int timestamp;
  final String price;
  final String driver;
  final double rating;
  final String status; // "completed" | "cancelled"
  final String pickup;
  final String dropoff;

  const RideModel({
    required this.id,
    required this.date,
    required this.timestamp,
    required this.price,
    required this.driver,
    required this.rating,
    required this.status,
    required this.pickup,
    required this.dropoff,
  });

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
