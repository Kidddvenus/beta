# Task Management Admin Portal

<p align="center">
  <img src="images/logo.png" alt="Logo" width="120" />
</p>

A cross-platform **Flutter** application for managing projects, employees, and tasks, with a Firebase-powered backend and AI/Cloud Function integrations. Designed for admin users to efficiently handle project management, employee records, and feedback in a modern, intuitive interface.

---

## 🚀 Features

<div align="center">

<table>
  <tr>
    <td><b>👤 Admin Authentication</b></td>
    <td><b>📋 Project & Task Management</b></td>
    <td><b>🧑‍💼 Employee & Manager Records</b></td>
  </tr>
  <tr>
    <td>Secure login for admins using Firebase Auth</td>
    <td>Create, view, and manage projects and tasks</td>
    <td>Add, view, and delete employees and project managers</td>
  </tr>
  <tr>
    <td><b>📊 Data Tables & PDF Export</b></td>
    <td><b>💬 Complaints & Compliments</b></td>
    <td><b>☁️ Cloud & AI Integration</b></td>
  </tr>
  <tr>
    <td>View and export project/task data as PDFs</td>
    <td>View and manage feedback from employees and managers</td>
    <td>Firebase, Firestore, Cloud Functions, Vertex AI, Genkit</td>
  </tr>
</table>

</div>

---

## 🖥️ Main Screens & User Flow

- **Login Screen:** Secure admin authentication
- **Home Screen:** Quick access to all management features
- **Add Project/Manager/Employee:** Forms to add new records
- **Add Task:** Assign tasks to employees
- **View Projects/Tasks:** Tabular view with export options
- **Delete Manager/Employee:** Remove records securely
- **Complaints/Compliments:** View feedback from both employees and managers
- **Logout:** Securely sign out

---

## 🏗️ Project Structure

- `lib/`
    - `authentication/` – Admin login and authentication logic
    - `main_screen/` – Home screen and navigation
    - `forms/` – Forms for adding projects, managers, employees, and tasks
    - `tables/` – Data tables for viewing projects and tasks
    - `cc/` – Complaints/Compliments modules for employees and managers
    - `deletion/` – Modules for deleting employees and managers
- `functions/` – Cloud Functions (Node.js & Python) for backend logic, AI, and automation
- `dataconnect/` – Data connector configuration for PostgreSQL and schema management
- `generated/` – Auto-generated code and API connectors

---

## ☁️ Cloud & AI Integrations

- **Firebase:**
    - Authentication, Firestore, Hosting
- **Cloud Functions:**
    - Node.js and Python functions for automation and backend logic
- **Vertex AI & Genkit:**
    - AI-powered features and flows (see `functions/src/index.ts`)
- **DataConnect:**
    - PostgreSQL integration and schema management

---

## 🛠️ Tech Stack

- **Flutter** (Dart)
- **Firebase** (Auth, Firestore, Hosting, Storage)
- **Cloud Functions** (Node.js, Python)
- **Vertex AI** (Google Cloud)
- **Genkit** (AI Orchestration)
- **PostgreSQL** (via DataConnect)

---

## 📱 Supported Platforms

- Android
- iOS
- Web
- Windows
- macOS
- Linux

---

## 🏁 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/beta2.git
   cd beta2
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Set up Firebase:**
    - Add your Firebase project configuration files (`google-services.json`, `GoogleService-Info.plist`, etc.)
    - Update `lib/firebase_options.dart` if needed
4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Google Cloud Vertex AI](https://cloud.google.com/vertex-ai)
- [Genkit](https://github.com/genkit-dev/genkit)

---

<p align="center">
  <b>Made with ❤️ for modern project management</b>
</p>
