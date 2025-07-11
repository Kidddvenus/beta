import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _tasksStream;
  late String _userId; // Variable to hold current user ID

  @override
  void initState() {
    super.initState();
    _tasksStream = _getTasksStream();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid; // Assign current user's ID to _userId
      });
    }
  }

  Stream<List<Map<String, dynamic>>> _getTasksStream() {
    return FirebaseFirestore.instance.collection('employees').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getFilteredTasksStream(String searchText) {
    return FirebaseFirestore.instance.collection('employees')
        .where('jobId', isEqualTo: searchText)
        .snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  Future<void> _saveAsPdf(List<Map<String, dynamic>> tasks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Job ID', 'First Name', 'Last Name', 'Department', 'Email', 'Phone', 'Task', 'Start Date', 'End Date'],
              ...tasks.map((task) => <String>[
                task['jobId'].toString(),
                task['firstName'].toString(),
                task['lastName'].toString(),
                task['department'].toString(),
                task['email'].toString(),  // Add Email
                task['phone'].toString(),  // Add Phone
                task['task']?.toString() ?? '', // Handle nullable task
                task['startDate']?.toString() ?? '', // Handle nullable startDate
                task['endDate']?.toString() ?? '', // Handle nullable endDate
              ]),
            ],
          ),
        ],
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tasks_table.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );

      // Open the PDF file for preview using the printing plugin
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'tasks_table.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  Future<void> _addTask(Map<String, dynamic> manager) async {
    final taskController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.cyan,
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(labelText: 'Task'),
                ),
                ListTile(
                  title: Text("Start Date: ${startDate != null ? startDate!.toLocal().toString().split(' ')[0] : 'Select Date'}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.lightGreen, // Set calendar's primary color to light green
                            ),
                          ),
                          child: child!,
                        );
                      },

                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text("End Date: ${endDate != null ? endDate!.toLocal().toString().split(' ')[0] : 'Select Date'}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.lightGreen, // Set calendar's primary color to light green
                            ),
                          ),
                          child: child!,
                        );
                      },

                    );
                    if (picked != null) {
                      setState(() {
                        endDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String task = taskController.text.trim();

                if (task.isEmpty || startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields must be filled')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('tasks').add({
                    'userId': _userId, // Include user ID
                    'jobId': manager['jobId'],
                    'firstName': manager['firstName'],
                    'lastName': manager['lastName'],
                    'department': manager['department'],
                    'task': task,
                    'startDate': startDate!.toIso8601String(),
                    'endDate': endDate!.toIso8601String(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task added successfully!')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add task: $e')),
                  );
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

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
        title: const Text('Add Task'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            onPressed: () async {
              final tasks = await _tasksStream.first;
              await _saveAsPdf(tasks);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.lightGreen, // Set background color to light green
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Job ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _tasksStream = _getTasksStream();
                  } else {
                    _tasksStream = _getFilteredTasksStream(value);
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _tasksStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks found.'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Job ID')),
                          DataColumn(label: Text('First Name')),
                          DataColumn(label: Text('Last Name')),
                          DataColumn(label: Text('Department')),
                          DataColumn(label: Text('Email')),  // Add Email column
                          DataColumn(label: Text('Phone')),  // Add Phone column
                          DataColumn(label: Text('Action')),
                        ],
                        rows: tasks.map((task) => DataRow(
                          cells: [
                            DataCell(Text(task['jobId'].toString())),
                            DataCell(Text(task['firstName'].toString())),
                            DataCell(Text(task['lastName'].toString())),
                            DataCell(Text(task['department'].toString())),
                            DataCell(Text(task['email']?.toString() ?? '')), // Handle nullable email
                            DataCell(Text(task['phone']?.toString() ?? '')), // Handle nullable phone
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _addTask(task),
                                tooltip: 'Add Task',
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
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

void main() {
  runApp(const MaterialApp(
    home: Tasks(),
  ));
}
