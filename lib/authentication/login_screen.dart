import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:beta/main_screen/home_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String adminEmail = "";
  String adminPassword = "";
  bool _obscurePassword = true; // To toggle password visibility

  void allowAdminToLogin() async {
    SnackBar snackbar = const SnackBar(
      content: Text(
        "Please Wait:",
        style: TextStyle(
          fontSize: 25,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.cyanAccent,
      duration: Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);

    User? currentAdmin;

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    ).then((fAuth) {
      currentAdmin = fAuth.user;
    }).catchError((onError) {
      // Display error message
      final snackbar = SnackBar(
        content: Text(
          "An error occurred: $onError",
          style: const TextStyle(
            fontSize: 35,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.cyanAccent,
        duration: const Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });

    if (currentAdmin != null) {
      // Check if admin exists
      await FirebaseFirestore.instance.collection("admins").doc(currentAdmin!.uid).get().then((snap) {
        if (snap.exists) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
        } else {
          SnackBar snackbar = const SnackBar(
            content: Text(
              "Admin Does Not Exist:",
              style: TextStyle(
                fontSize: 35,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.cyanAccent,
            duration: Duration(seconds: 5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // Adjusted for responsiveness
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image
                  Image.asset("images/logo.png"),
                  // Email text field
                  TextField(
                    onChanged: (value) {
                      adminEmail = value;
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.cyan,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.cyanAccent,
                        ),
                      ),
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.white),
                      icon: Icon(
                        Icons.email,
                        color: Colors.cyan,
                      ),
                    ),
                  ),
                  // Spacing between text fields
                  const SizedBox(height: 20),
                  // Password text field
                  TextField(
                    onChanged: (value) {
                      adminPassword = value;
                    },
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.cyan,
                          width: 2,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.cyanAccent,
                        ),
                      ),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white),
                      icon: const Icon(
                        Icons.password,
                        color: Colors.cyan,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.cyan,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      allowAdminToLogin();
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3, vertical: 20)), // Responsive padding
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.cyan),
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.purple),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
