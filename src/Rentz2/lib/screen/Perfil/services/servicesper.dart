class ProfileService {
  Future<Map<String, String>> getProfileData() async {
    await Future.delayed(Duration(seconds: 1)); // Simula una llamada a la API
    return {
      'name': 'Jesus Gamboa',
      'email': 'hola915@gmail.com',
      'phone': '+52 123 456 7890',
      'image': 'https://via.placeholder.com/150',
    };
  }
}
