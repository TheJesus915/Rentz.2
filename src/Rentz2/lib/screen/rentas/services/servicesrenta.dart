class RentalService {
  static List<Map<String, dynamic>> getRentals() {
    return [
      {
        'id': 749,
        'title': 'Paquete de mesas y sillas para fiestas',
        'status': 'activa',
        'image': 'assets/images/active_rental.png',
      },
      {
        'id': 748,
        'title': 'Paquete de boda con 15 sillas y 1 mesa',
        'status': 'antigua',
        'image': 'assets/images/old_rental.png',
      },
    ];
  }
}