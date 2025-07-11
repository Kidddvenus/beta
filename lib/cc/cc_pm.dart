import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplainComplementDisplay extends StatelessWidget {
  const ComplainComplementDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complain/Complement Display'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.blueAccent],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.cyanAccent, // Set the background color to light blue
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('complain_complement_p')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data;

            if (data == null || data.docs.isEmpty) {
              return const Center(child: Text('No complains/complements found.'));
            }

            return ListView.builder(
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                final doc = data.docs[index];
                final complainOrComplement = doc['complainOrComplement'];
                final timestamp = doc['timestamp'] != null
                    ? (doc['timestamp'] as Timestamp).toDate().toString()
                    : 'No Timestamp';

                return ListTile(
                  title: Text('Complain/Complement: $complainOrComplement'),
                  subtitle: Text('Timestamp: $timestamp'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ComplainComplementDisplay(),
  ));
}
