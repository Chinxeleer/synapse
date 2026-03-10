# 🌍 Synapse: AI Lens & Sign Bridge

**Synapse** is a premium, real-time visual translation platform built with Flutter. It bridges communication gaps by instantly converting foreign text and Sign Language into your native language using on-device AI.

---

## 🚀 Vision & Problem
Traditional translation apps are slow, data-heavy, and exclude the Deaf and Hard-of-Hearing community. **Synapse** solves this with:
- **Zero-Latency OCR:** Local processing—no image uploads required.
- **Inclusive Design:** A dedicated mode for Sign Language (ASL) to text/speech.
- **Premium Experience:** A high-performance, glassmorphic UI designed for the modern user.

## 🛠 Tech Stack
- **Framework:** Flutter (3.24+)
- **State Management:** Riverpod (for scalable, testable state)
- **Camera Engine:** `camerawesome` (high-performance image stream analysis)
- **AI/ML:** Google ML Kit (Text Recognition & Pose Detection)
- **UI Architecture:** Glassmorphism via `BackdropFilter` & Shaders

---

## 📂 Project Structure (Feature-First Architecture)
We follow a **Feature-First Clean Architecture** to ensure the code remains modular and maintainable as we scale from MVP to a global product.

```text
lib/
├── core/                        # Global Shared Layer
│   ├── constants/               # App colors (Neon Cyan), API Keys, Styles
│   ├── theme/                   # Glassmorphism & Dark Mode logic
│   ├── utils/                   # Image processors & Format converters
│   └── widgets/                 # Reusable UI (Custom Buttons, Loaders)
├── features/                    # Business Logic by Feature
│   ├── onboarding/              # Welcome & Mode Selection
│   │   └── presentation/        # Home screen UI & Logic
│   ├── text_translation/        # OCR Feature
│   │   ├── data/                # API Repositories
│   │   ├── domain/              # Translation Use-cases
│   │   └── presentation/        # Camera Viewfinder & Result Sheet
│   └── sign_language/           # Sign Language Feature
│       ├── data/                # Pose Mapping Data
│       ├── domain/              # Gesture Recognition Logic
│       └── presentation/        # Live Pose Overlay & Subtitle Bar
├── services/                    # Hardware & Infrastructure
│   ├── camera_service.dart      # Singleton Camera Controller
│   └── ml_kit_service.dart      # ML Kit Text/Pose central hub
├── app.dart                     # Main App Entry & Routing
└── main.dart                    # Initialization & Providers