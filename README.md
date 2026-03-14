# MedNotify 💊

> *A comprehensive Flutter medicine reminder app for managing medications, appointments, and health records — built with care for better health management.*

---

## What is MedNotify?

MedNotify is a feature-rich medicine management application built with Flutter and Hive for local data storage. From medication reminders to appointment tracking, everything is designed to help users manage their health efficiently with an intuitive and beautiful interface.

---

## ✨ Features

| Feature | Description |
|---|---|
| 💊 **Medicine Management** | Add, edit, and manage medications with dosage and timing |
| ⏰ **Smart Reminders** | Local notifications for medicine intake and appointments |
| 📅 **Appointment Scheduling** | Manage doctor and test appointments |
| 📋 **Medicine Stock** | Track and manage medicine inventory |
| 📊 **Health History** | View doctor visit history and test reports |
| 🔔 **Push Notifications** | Timely reminders for medications and appointments |
| 📱 **Modern UI** | Clean and intuitive Material Design interface |
| 💾 **Local Storage** | Offline data persistence with Hive database |

---

## 🛠️ Tech Stack

```
Flutter               →  Cross-platform mobile framework
Hive                  →  Local NoSQL database for data persistence
Local Notifications   →  Native notification system
Table Calendar        →  Calendar widget for appointment viewing
Time Zone             →  Time zone management for scheduling
Image Picker          →  Camera and gallery integration
Material Design       →  Modern UI design system
```

---

## 📦 Dependencies

```yaml
flutter_local_notifications: ^18.0.1
hive: ^2.2.3
hive_flutter: ^1.1.0
table_calendar: ^3.1.1
flutter_time_picker_spinner: ^2.0.0
flutter_timezone: ^3.0.1
image_picker: ^1.1.2
icofont_flutter: ^1.4.0
path_provider: ^2.1.3
intl: ^0.19.0
rxdart: ^0.28.0
permission_handler: ^12.0.1
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point and initialization
├── local_notifications.dart         # Notification service setup
├── permission_handler.dart          # Permission management
├── model/                           # Data models and adapters
│   ├── medicine_model.dart          # Medicine data structure
│   ├── appointment_model.dart       # Appointment data structure
│   ├── testappointment.dart         # Test appointment model
│   ├── dochistory.dart              # Doctor visit history
│   └── test_history.dart            # Test history model
├── screens/                         # UI screens
│   ├── welcome_screen.dart          # Welcome/onboarding screen
│   ├── home_screen_widget.dart      # Main dashboard
│   ├── med_add_screen.dart          # Add medicine screen
│   ├── medications_list_screen.dart # Medicine list view
│   ├── doctor_appointment.dart      # Doctor appointment booking
│   ├── testappointment.dart         # Test appointment booking
│   ├── history_screeen.dart         # Health history view
│   ├── medicine_stock.dart          # Medicine inventory
│   └── settings_screen.dart        # App settings
├── widgets/                         # Reusable UI components
├── utils/                           # Utility functions
├── notification_helper/             # Notification helpers
└── ui_colors/                       # App color scheme
```

---

<p align="center">Made with ❤️ using Flutter for better health management</p>