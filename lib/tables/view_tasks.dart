import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class ViewTasks extends StatefulWidget {
  const ViewTasks({super.key});

  @override
  _ViewTasksState createState() => _ViewTasksState();
}

class _ViewTasksState extends State<ViewTasks> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _tasksStream;

  @override
  void initState() {
    super.initState();
    _tasksStream = _getTasksStream();
  }

  Stream<List<Map<String, dynamic>>> _getTasksStream() {
    return FirebaseFirestore.instance.collection('tasks').snapshots().asyncMap((snapshot) async {
      final tasks = snapshot.docs.map((doc) => doc.data()).toList();

      // Fetch employee data to get email and phone details
      final employeeData = await _getEmployeesData(tasks);

      // Merge employee data with tasks
      return tasks.map((task) {
        final employee = employeeData[task['jobId']] ?? {};
        return {
          ...task,
          'email': employee['email'] ?? '',
          'phone': employee['phone'] ?? '',
        };
      }).toList();
    });
  }

  Future<Map<String, Map<String, dynamic>>> _getEmployeesData(List<Map<String, dynamic>> tasks) async {
    final employeeData = <String, Map<String, dynamic>>{};

    // Fetch employee details
    final employeesSnapshot = await FirebaseFirestore.instance.collection('employees').get();
    for (var doc in employeesSnapshot.docs) {
      employeeData[doc['jobId']] = doc.data();
    }

    return employeeData;
  }

  Stream<List<Map<String, dynamic>>> _getFilteredTasksStream(String searchText) {
    return FirebaseFirestore.instance.collection('tasks')
        .where('jobId', isEqualTo: searchText)
        .snapshots().asyncMap((snapshot) async {
      final tasks = snapshot.docs.map((doc) => doc.data()).toList();

      // Fetch employee data to get email and phone details
      final employeeData = await _getEmployeesData(tasks);

      // Merge employee data with tasks
      return tasks.map((task) {
        final employee = employeeData[task['jobId']] ?? {};
        return {
          ...task,
          'email': employee['email'] ?? '',
          'phone': employee['phone'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> _saveAsPdf(List<Map<String, dynamic>> tasks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Job ID', 'First Name', 'Last Name', 'Department', 'Task', 'Start Date', 'End Date', 'Email', 'Phone'],
              ...tasks.map((task) => <String>[
                task['jobId'].toString(),
                task['firstName'].toString(),
                task['lastName'].toString(),
                task['department'].toString(),
                task['task'].toString(),
                task['startDate'].toString(),
                task['endDate'].toString(),
                task['email'].toString(),
                task['phone'].toString(),
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
        title: const Text('View Tasks'),
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
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Job ID')),
                          DataColumn(label: Text('First Name')),
                          DataColumn(label: Text('Last Name')),
                          DataColumn(label: Text('Department')),
                          DataColumn(label: Text('Task')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('End Date')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Phone')),
                        ],
                        rows: tasks.map((task) => DataRow(
                          cells: [
                            DataCell(Text(task['jobId'].toString())),
                            DataCell(Text(task['firstName'].toString())),
                            DataCell(Text(task['lastName'].toString())),
                            DataCell(Text(task['department'].toString())),
                            DataCell(Text(task['task'].toString())),
                            DataCell(Text(task['startDate'].toString())),
                            DataCell(Text(task['endDate'].toString())),
                            DataCell(Text(task['email'].toString())),  // New email column
                            DataCell(Text(task['phone'].toString())),  // New phone column
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
    home: ViewTasks(),
  ));
}
