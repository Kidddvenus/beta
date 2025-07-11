import 'dart:async';
import 'package:beta/Tables/view_project.dart';
import 'package:beta/Tables/view_tasks.dart';
import 'package:beta/cc/cc_emp.dart';
import 'package:beta/cc/cc_pm.dart';
import 'package:beta/deletion/delete_emp.dart';
import 'package:beta/deletion/delete_pm.dart';
import 'package:beta/forms/add_emp.dart';
import 'package:beta/forms/add_pm.dart';
import 'package:beta/forms/add_project.dart';
import 'package:beta/forms/add_tasks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beta/authentication/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String timeText = "";
  String dateText = "";

  String formatCurrentLiveTime(DateTime time) {
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date) {
    return DateFormat("dd MMMM yyyy").format(date);
  }

  void getCurrentLiveTime() {
    final DateTime timeNow = DateTime.now();
    final String liveTime = formatCurrentLiveTime(timeNow);
    final String liveDate = formatCurrentDate(timeNow);

    if (mounted) {
      setState(() {
        timeText = liveTime;
        dateText = liveDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      getCurrentLiveTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        title: const Text(
          "Welcome To Admin Portal",
          style: TextStyle(fontSize: 18, letterSpacing: 3),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "$timeText\n$dateText",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.cyan,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Add and remove employee
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add, color: Colors.purple),
                    label: Text(
                      "Add ProjectManager".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FormScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add, color: Colors.purple),
                    label: Text(
                      "Add Employee".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Employees()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Add task and view accounts
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline_outlined, color: Colors.green),
                    label: Text(
                      "Add Project To Manager".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddProject()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline_outlined, color: Colors.green),
                    label: Text(
                      "Add Task To Employee".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Tasks()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // View projects and tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, color: Colors.deepOrange),
                    label: Text(
                      "View Projects".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 3.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProjectsTable()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, color: Colors.deepOrange),
                    label: Text(
                      "View Tasks".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 3.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ViewTasks()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Delete manager and employee
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.block, color: Colors.red),
                    label: Text(
                      "Delete Manager".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 4,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DeleteProjectManagerScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.block, color: Colors.pink),
                    label: Text(
                      "Delete Employee".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 2.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DeleteEmp()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, color: Colors.brown),
                    label: Text(
                      "Complain/Compliment".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ComplainComplementDisplay()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, color: Colors.brown),
                    label: Text(
                      "Complain/Compliment".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CcEmp()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Logout button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.cyanAccent),
              label: Text(
                "Log Out".toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.grey,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
