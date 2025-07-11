import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _tasksStream;
  late String _userId; // Variable to hold current user ID

  @override
  void initState() {
    super.initState();
    _tasksStream = _getProjectsStream();
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

  Stream<List<Map<String, dynamic>>> _getProjectsStream() {
    return FirebaseFirestore.instance.collection('projectManagers')
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs.map((doc) =>
        {
          ...doc.data(),
          'email': doc['email'],
          'phone': doc['phone'],
        }).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getFilteredProjectsStream(
      String searchText) {
    return FirebaseFirestore.instance.collection('projectManagers')
        .where('jobId', isEqualTo: searchText)
        .snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) =>
        {
          ...doc.data(),
          'email': doc['email'],
          'phone': doc['phone'],
        }).toList();
      },
    );
  }

  Future<void> _saveAsPdf(List<Map<String, dynamic>> projects) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) =>
        [
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>[
                'Job ID',
                'First Name',
                'Last Name',
                'Department',
                'Email',
                'Phone', // Added Phone column
                'Project',
                'Start Date',
                'End Date'
              ],
              ...projects.map((project) =>
              <String>[
                project['jobId'].toString(),
                project['firstName'].toString(),
                project['lastName'].toString(),
                project['department'].toString(),
                project['email'].toString(), // Email column
                project['phone'].toString(), // Phone column
                '', // Placeholder for Project
                '', // Placeholder for Start Date
                '', // Placeholder for End Date
              ]),
            ],
          ),
        ],
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/projects_table.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );

      // Open the PDF file for preview using the printing plugin
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'projects_table.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  Future<void> _addProject(Map<String, dynamic> manager) async {
    final projectController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
                  backgroundColor: Colors.cyan,
                  // Set background color of the dialog to cyan
                  title: const Text('Add Project'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: projectController,
                          decoration: const InputDecoration(
                              labelText: 'Project'),
                        ),
                        ListTile(
                          title: Text("Start Date: ${startDate != null
                              ? startDate!.toLocal().toString().split(' ')[0]
                              : 'Select Date'}"),
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
                                      primary: Colors
                                          .lightGreen, // Set calendar's primary color to light green
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
                          title: Text("End Date: ${endDate != null
                              ? endDate!.toLocal().toString().split(' ')[0]
                              : 'Select Date'}"),
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
                                      primary: Colors
                                          .lightGreen, // Set calendar's primary color to light green
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
                        final String project = projectController.text.trim();

                        if (project.isEmpty || startDate == null ||
                            endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('All fields must be filled')),
                          );
                          return;
                        }

                        try {
                          await FirebaseFirestore.instance.collection(
                              'projects').add({
                            'userId': _userId, // Include user ID
                            'jobId': manager['jobId'],
                            'firstName': manager['firstName'],
                            'lastName': manager['lastName'],
                            'department': manager['department'],
                            'project': project,
                            'startDate': startDate!.toIso8601String(),
                            'endDate': endDate!.toIso8601String(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Project added successfully!')),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to add project: $e')),
                          );
                        }
                      },
                      child: const Text('Add Project'),
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
        title: const Text('Add Project'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            onPressed: () async {
              final projects = await _tasksStream.first;
              await _saveAsPdf(projects);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlueAccent, // Set background color to light blue
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
                    _tasksStream = _getProjectsStream();
                  } else {
                    _tasksStream = _getFilteredProjectsStream(value);
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

                  final projects = snapshot.data ?? [];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Job ID')),
                        DataColumn(label: Text('First Name')),
                        DataColumn(label: Text('Last Name')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Email')), // Email column
                        DataColumn(label: Text('Phone')), // Phone column
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: projects.map((project) {
                        return DataRow(
                          cells: [
                            DataCell(Text(project['jobId'].toString())),
                            DataCell(Text(project['firstName'].toString())),
                            DataCell(Text(project['lastName'].toString())),
                            DataCell(Text(project['department'].toString())),
                            DataCell(Text(project['email'].toString())),
                            // Email cell
                            DataCell(Text(project['phone'].toString())),
                            // Phone cell
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _addProject(project),
                                    tooltip: 'Add project',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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