import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Employees extends StatefulWidget {
  const Employees({super.key});

  @override
  _EmployeesState createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  final TextEditingController _jobIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final CollectionReference employees =
  FirebaseFirestore.instance.collection('employees');
  final CollectionReference empAuth =
  FirebaseFirestore.instance.collection('emp_auth');

  void _submitData() async {
    final String jobId = _jobIdController.text.trim();
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String nationalId = _nationalIdController.text.trim();
    final String age = _ageController.text.trim();
    final String department = _departmentController.text.trim();
    final String email = _emailController.text.trim();

    if (jobId.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        nationalId.isEmpty ||
        age.isEmpty ||
        department.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled')),
      );
      return;
    }

    try {
      // Check if an employee with the same jobId already exists
      QuerySnapshot existingEmployees = await employees
          .where('jobId', isEqualTo: jobId)
          .get();

      if (existingEmployees.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An employee with this Job ID already exists')),
        );
        return;
      }

      // Create the user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: jobId);

      // Get the user UID generated during authentication
      String userUid = userCredential.user!.uid;

      // Add the user details to Firestore (employees collection)
      await employees.doc(userUid).set({
        'jobId': jobId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'nationalId': nationalId,
        'age': age,
        'department': department,
        'email': email,
      });

      // Add email and name to empAuth collection using the same UID
      await empAuth.doc(userUid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data added successfully!')),
      );

      // Clear text fields after successful submission
      _jobIdController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      _nationalIdController.clear();
      _ageController.clear();
      _departmentController.clear();
      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightGreen,
                Colors.blueAccent,
              ],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.lightGreen, // Set the background color to light blue
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _jobIdController,
                decoration: const InputDecoration(labelText: 'Job ID'),
              ),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _nationalIdController,
                decoration: const InputDecoration(labelText: 'National ID'),
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Employees(),
  ));
}
