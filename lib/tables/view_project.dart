import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class ProjectsTable extends StatefulWidget {
  const ProjectsTable({super.key});

  @override
  _ProjectsTableState createState() => _ProjectsTableState();
}

class _ProjectsTableState extends State<ProjectsTable> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _projectsStream;

  @override
  void initState() {
    super.initState();
    _projectsStream = _getProjectsStream();
  }

  Stream<List<Map<String, dynamic>>> _getProjectsStream() {
    return FirebaseFirestore.instance.collection('projects').snapshots().asyncMap((snapshot) async {
      final projects = snapshot.docs.map((doc) => doc.data()).toList();
      return await _mergeWithProjectManagerData(projects);
    });
  }

  Future<List<Map<String, dynamic>>> _mergeWithProjectManagerData(List<Map<String, dynamic>> projects) async {
    final projectManagerData = await _getProjectManagerData();

    return projects.map((project) {
      final projectManager = projectManagerData[project['jobId']] ?? {};
      return {
        ...project,
        'email': projectManager['email'] ?? '',
        'phone': projectManager['phone'] ?? '',
      };
    }).toList();
  }

  Future<Map<String, Map<String, dynamic>>> _getProjectManagerData() async {
    final projectManagerData = <String, Map<String, dynamic>>{};
    final projectManagersSnapshot = await FirebaseFirestore.instance.collection('projectManagers').get();

    for (var doc in projectManagersSnapshot.docs) {
      projectManagerData[doc['jobId']] = doc.data();
    }

    return projectManagerData;
  }

  Stream<List<Map<String, dynamic>>> _getFilteredProjectsStream(String searchText) {
    return FirebaseFirestore.instance.collection('projects')
        .where('jobId', isEqualTo: searchText)
        .snapshots().asyncMap((snapshot) async {
      final projects = snapshot.docs.map((doc) => doc.data()).toList();
      return await _mergeWithProjectManagerData(projects);
    });
  }

  Future<void> _saveAsPdf(List<Map<String, dynamic>> projects) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Job ID', 'First Name', 'Last Name', 'Department', 'Project', 'Start Date', 'End Date', 'Email', 'Phone'],
              ...projects.map((project) => <String>[
                project['jobId'].toString(),
                project['firstName'].toString(),
                project['lastName'].toString(),
                project['department'].toString(),
                project['project'].toString(),
                project['startDate'].toString(),
                project['endDate'].toString(),
                project['email'].toString(),
                project['phone'].toString(),
              ]),
            ],
          ),
        ],
      ),
    );

    try {
      // Request permission to write to storage
      if (await Permission.storage.request().isGranted) {
        final directory = await getApplicationDocumentsDirectory(); // Use application documents directory
        final file = File('${directory.path}/projects_table.pdf');
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to ${file.path}')),
        );

        // Open the PDF file for preview using the printing plugin
        await Printing.sharePdf(bytes: await pdf.save(), filename: 'projects_table.pdf');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
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
                Colors.blueAccent,
              ],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text('Projects Table'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            onPressed: () async {
              final projects = await _projectsStream.first;
              await _saveAsPdf(projects);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlue, // Set the background color to light blue
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
                    _projectsStream = _getProjectsStream();
                  } else {
                    _projectsStream = _getFilteredProjectsStream(value);
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _projectsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final projects = snapshot.data ?? [];

                  if (projects.isEmpty) {
                    return const Center(child: Text('No projects found.'));
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
                          DataColumn(label: Text('Project')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('End Date')),
                          DataColumn(label: Text('Email')), // Email column from projectManagers
                          DataColumn(label: Text('Phone')), // Phone column from projectManagers
                        ],
                        rows: projects.map((project) => DataRow(
                          cells: [
                            DataCell(Text(project['jobId'].toString())),
                            DataCell(Text(project['firstName'].toString())),
                            DataCell(Text(project['lastName'].toString())),
                            DataCell(Text(project['department'].toString())),
                            DataCell(Text(project['project'].toString())),
                            DataCell(Text(project['startDate'].toString())),
                            DataCell(Text(project['endDate'].toString())),
                            DataCell(Text(project['email'].toString())),  // Email cell from projectManagers
                            DataCell(Text(project['phone'].toString())),  // Phone cell from projectManagers
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
    home: ProjectsTable(),
  ));
}
