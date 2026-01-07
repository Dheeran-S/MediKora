# 💊 Medikora – Smart AI-Powered Medication & Health Assistant
> **Note**: This is the **Main Submission Repository** for the Hackathon Final.

Medikora is a comprehensive, AI-driven healthcare ecosystem designed to bridge the gap between patients and medical facilities. Built with **Flutter** for a seamless cross-platform mobile experience and powered by **Firebase** for real-time data synchronization, Medikora ensures users stay on top of their health while providing hospitals with a robust management interface.

---

## 📌 Overview

**Medikora** integrates intelligent medication scheduling, doctor appointment booking, and AI-assisted health consultations into a single, cohesive application. It leverages **Google's Generative AI (Gemini)** to provide context-aware health insights and simplifies the patient journey from prescription to recovery.

The ecosystem consists of:
1.  **Medikora Mobile App**: For patients to manage health, book appointments, and chat with AI.
2.  **Hospital & Admin Web Portal**: For hospitals to manage doctor registries, verify appointments, and oversee operations.

---

## ✨ Key Features & Technical Highlights

### 🏥 Smart Doctor Booking System
-   **Real-time Availability**: seamlessly checks doctor slots using real-time Firestore listeners.
-   **Instant Booking**: Users can search for specialists and book appointments instantly, with immediate confirmation updates reflecting across the platform.

### 🕒 Robust Medication Scheduler
-   **Reliable Notifications**: Built using `flutter_local_notifications` to ensure critical dose reminders are delivered even when the app is in the background or offline.
-   **Local Persistence**: Utilizes **SQLite** to cache schedules locally, ensuring users have access to their medication plan without internet connectivity.

### 🤖 Gemini AI Health Assistant
-   **Context-Aware Advice**: Integrated directly with **Google Generative AI SDK (Gemini)** to interpret user queries and provide health tips, medication info, and wellness guidance.
-   **Interactive Chat**: A responsive chat interface (`health_chat_screen.dart`) that maintains conversation context for a natural user experience.

### 🔐 Secure & Role-Based Access
-   **Firebase Authentication**: Secure login flow with support for multiple auth providers.
-   **Profile Management**: Dedicated user profiles stored in **Cloud Firestore**, allowing for personalized experiences and secure data handling.

### 📄 Prescription Scanning (AI-Ready)
-   **Image Processing**: Efficient image capture and processing pipeline for digitizing prescriptions.
-   **OCR Readiness**: Architecture structured to support Optical Character Recognition for automated data extraction.

---

## 💻 Hospital Administration Portal (Web App)

A specialized Web Dashboard designed exclusively for hospital administrators. This portal serves as the control center for the Medikora ecosystem.

**Features:**
-   **Hospital Registration & Login**: Secure onboarding for medical facilities.
-   **Doctor Management**: Add, update, and manage doctor profiles and specialties.
-   **Appointment Oversight**: View and manage incoming patient appointments in real-time.

| Resource | Link |
| :--- | :--- |
| **Repository** | [LINK_TO_BE_ADDED] |
| **Live Deployment** | [LINK_TO_BE_ADDED] |

---

## 🧑‍💻 Technology Stack

### Mobile Application (Flattened Architecture)
-   **Framework**: [Flutter](https://flutter.dev) (Dart)
-   **State Management**: `Provider` for efficient, scalable state handling.
-   **Architecture**: MVVM-inspired layered architecture separating UI, Services, and Models.

### Backend & Cloud Services (Serverless)
-   **Auth**: Firebase Authentication (RBAC capabilities).
-   **Database**: 
    -   **Cloud Firestore**: NoSQL DB for real-time user, doctor, and appointment data.
    -   **Realtime Database**: For low-latency chat and status updates.
-   **Storage**: Firebase Cloud Storage for profile images and prescription uploads.
-   **Notifications**: Firebase Cloud Messaging (FCM) coupled with local scheduling.

### Artificial Intelligence
-   **LLM**: Google Gemini Pro (via `google_generative_ai` package).

---

## 📦 Project Structure

```
lib/
├── screens/          # UI Layers (Home, Appointments, Chat, Profile, etc.)
├── widgets/          # Reusable, atomic UI components
├── models/           # Dart data class definitions (User, Doctor, Appointment)
├── services/         # Business logic & API calls (AuthService, DatabaseService)
├── utils/            # Constants, Themes, and Helper functions
└── main.dart         # Entry point & App Configuration
```

---

## 🚀 Getting Started

### Prerequisites
-   Flutter SDK (Stable Channel)
-   Dart SDK
-   Firebase Project Configuration

### Installation
1.  **Clone the Repository**
    ```bash
    git clone https://github.com/aravind5423/L.EIC017.git
    cd L.EIC017
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**
    -   Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to their respective directories.

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 👥 Authors

**Aravind Kumar S**  
GitHub: [aravind5423](https://github.com/aravind5423)

**Dheeran Sankaran**  
GitHub: [Dheeran-S](https://github.com/Dheeran-S)

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
