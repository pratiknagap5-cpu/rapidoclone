# 🏍️ Rapido Clone - Ride Booking App

![Rapido Banner](assets/images/banner.png)

A feature-rich, high-performance ride-sharing application built with **Flutter** and **Spring Boot**. This project replicates the core functionality of Rapido, including ride booking, real-time location tracking, and wallet management.

## 🚀 Live Demo

Check out the live web version of the app here:
👉 **[https://pratiknagap5-cpu.github.io/rapidoclone/](https://pratiknagap5-cpu.github.io/rapidoclone/)**

---

## ✨ Features

- **📍 Real-time Maps**: Integrated with OpenStreetMap (OSM) and OSRM for free, high-quality routing and distance calculation.
- **📱 Responsive UI**: A premium, state-of-the-art mobile and web interface using modern Flutter widgets.
- **📂 State Management**: Powered by **Riverpod** for robust, reactive, and scalable state handling.
- **💾 Offline First**: Uses **Hive** for fast, local data persistence.
- **💳 Wallet & Payments**: Complete flow for adding money to the wallet and paying for rides.
- **📊 Ride History**: Track all your past rides, distances, and fares.
- **🛡️ Secure Auth**: OTP-based login system (requires backend connectivity for full SMS flow).

---

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: flutter_riverpod
- **Database**: Hive (Local storage)
- **Maps**: flutter_map, latlong2
- **Routing**: OSRM API (Open Source Routing Machine)
- **Theming**: Custom Premium Dark/Light Mode

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.x
- **Database**: MongoDB / SQL (configurable)
- **API**: RESTful Services for OTP, User Management, and Ride persistence.
- **Build Tool**: Maven

---

## 📦 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Java 17+](https://www.oracle.com/java/technologies/downloads/)
- [Maven](https://maven.apache.org/download.cgi)

### Installation

1. **Clone the repository**:
   ```ps1
   git clone https://github.com/pratiknagap5-cpu/rapidoclone.git
   cd rapidoclone
   ```

2. **Frontend Setup**:
   ```ps1
   flutter pub get
   flutter run
   ```

3. **Backend Setup**:
   ```ps1
   cd backend
   mvn spring-boot:run
   ```

---

## 🏗️ Architecture

The project follows a modular, clean architecture:
- **`lib/models`**: Data structures and Hive adapters.
- **`lib/providers`**: Riverpod state management logic.
- **`lib/screens`**: UI components and views.
- **`lib/services`**: API integrations and business logic.
- **`backend/`**: Spring Boot controllers and business services.

---

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Built with ❤️ for the Flutter community.*
