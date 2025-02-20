import 'package:flutter/material.dart';
import 'services/servicesrenta.dart';



class RentalHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rentals = RentalService.getRentals();
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de rentas'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historial de rentas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  final rental = rentals[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12.0),
                      leading: Image.asset(rental['image'], width: 50, height: 50, fit: BoxFit.cover),
                      title: Text('Ticket Número ${rental['id']}'),
                      subtitle: Text(rental['title']),
                      trailing: rental['status'] == 'activa'
                          ? Icon(Icons.circle, color: Colors.green)
                          : Icon(Icons.circle, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}