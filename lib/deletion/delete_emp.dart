import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteEmp extends StatelessWidget {
  const DeleteEmp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightGreen,
                Colors.blue,
              ],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text('Delete Employee'),
      ),
      body: Container(
        color: Colors.lightGreen, // Set background color to light green
        child: const Center(
          child: DeleteForm(),
        ),
      ),
    );
  }
}

class DeleteForm extends StatefulWidget {
  const DeleteForm({super.key});

  @override
  _DeleteFormState createState() => _DeleteFormState();
}

class _DeleteFormState extends State<DeleteForm> {
  final TextEditingController _jobIdController = TextEditingController();

  Future<void> _deleteEmployee(String jobId) async {
    try {
      // Query Firestore to find document(s) with matching jobId in employees collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('jobId', isEqualTo: jobId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No employee found with Job ID: $jobId')),
        );
        return;
      }

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete employee with Job ID: $jobId?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false when cancel button is pressed
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true when delete button is pressed
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Delete each document found with matching jobId in employees collection
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
          print('Document with ID ${doc.id} from employees collection successfully deleted.');
        }

        // Query Firestore to find document(s) with matching jobId in tasks collection
        final tasksQuerySnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('jobId', isEqualTo: jobId)
            .get();

        // Delete each document found with matching jobId in tasks collection
        for (var doc in tasksQuerySnapshot.docs) {
          await doc.reference.delete();
          print('Document with ID ${doc.id} from tasks collection successfully deleted.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee and associated tasks deleted successfully')),
        );
      }
    } catch (e) {
      print('Failed to delete document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete Employee(s): $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _jobIdController,
            decoration: const InputDecoration(
              labelText: 'Enter Job ID',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              String jobId = _jobIdController.text.trim();
              if (jobId.isNotEmpty) {
                _deleteEmployee(jobId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a Job ID')),
                );
              }
            },
            child: const Text('Delete Employee'),
          ),
        ],
      ),
    );
  }
}
