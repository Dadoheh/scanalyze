# Scanalyze

Scanalyze is a comprehensive mobile application for analyzing cosmetic products and their ingredients based on individual user health profiles. The app helps users make informed decisions about cosmetic products by evaluating potential risks based on their specific skin conditions, allergies, medications, and lifestyle factors.

---

## Overview

The Scanalyze project consists of two main components:

- **Flutter Mobile Application**: User-friendly interface for profile creation, product scanning, and viewing personalized recommendations
- **FastAPI Backend**: REST API service for user authentication, profile management, and sophisticated cosmetic ingredient analysis

---

## Features

### User Authentication & Profile Management

- Secure registration and login with JWT authentication
- Detailed user profile creation with health data storage

### Comprehensive User Profile Collection

- **Physiological Features**: Age, gender, weight, height
- **Skin Characteristics**: Type (dry/oily/mixed/normal), sensitivity, atopic conditions
- **Allergies & Sensitivities**: Cosmetic allergens, general allergies
- **Dermatological Conditions**: Acne vulgaris, psoriasis, eczema, rosacea
- **Medications**: Photosensitizing drugs, diuretics, other medications
- **Lifestyle Factors**: Smoking habits, stress level, sun exposure/tanning, pregnancy

### Cosmetic Product Analysis

- Ingredient parsing and evaluation
- Personalized safety assessment based on user profile
- Risk identification for specific ingredients

---

## Technology Stack

### Frontend (Mobile App)

- **Flutter/Dart**: Cross-platform mobile application framework
- **Key packages**:
    - `provider`: State management
    - `http`: API communication
    - `shared_preferences`: Local data storage
    - `fluttertoast`: User notifications

### Backend

- **FastAPI**: High-performance Python web framework
- **MongoDB**: NoSQL database for data storage
- **PyJWT**: JSON Web Token implementation
- **Motor**: Asynchronous MongoDB driver
- **Docker/Docker Compose**: Containerization for deployment

---

## Knowledge Graph & Analysis Pipeline

### Knowledge Integration

- External regulatory databases (CosIng, SCCS)
- EU allergen lists
- QSAR data (phototoxicity, LD50, permeability)
- Clinical contraindications (pregnancy, medications, diseases)

### Safety Assessment Engine

#### Ingredient Parsing

- INCI tokenization and mapping to CAS/SMILES identifiers
- Identification in Knowledge Graph

#### Rule-based Analysis

- Allergen detection based on user profile
- Phototoxicity risk assessment for users on photosensitizing drugs
- Pregnancy-related contraindications

#### Machine Learning Classification

- Feature extraction from user profiles and ingredients
- Risk classification (safe vs. unsafe, or low/medium/high risk)
- Explainable AI using LIME or SHAP for risk factor identification

### Explanation Module

- User-friendly explanations of identified risks
- Detailed ingredient breakdowns with risk attribution

---

## Example User Flow

1. User creates a detailed health profile
2. User scans a cosmetic product or enters ingredient list
3. System parses ingredients and maps to knowledge graph
4. Rule engine identifies immediate concerns (e.g., known allergens)
5. ML classifier evaluates overall risk level
6. User receives personalized safety assessment with explanations:
    - "Ingredient X is phototoxic (user is taking diuretics)"
    - "Ingredient Y has excessive permeability for atopic skin"

---

## Implementation Details

### Frontend Architecture

- Screens for user registration, profile management, product scanning
- Profile data collection across multiple form pages
- Results visualization with detailed explanations

### Backend Architecture

- RESTful API endpoints for user management and profile storage
- Sophisticated analysis pipeline for ingredient evaluation
- Personalized recommendation engine

---

## Getting Started

For developers interested in contributing to or using Scanalyze:

### Prerequisites

- Flutter SDK (3.1.0+)
- Python 3.11+ (for backend development)
- Docker and Docker Compose (for containerized deployment)

### Installation

1. Clone the repository
2. Set up environment variables for backend
3. Run the backend using Docker Compose
4. Build and run the Flutter application

---

Scanalyze aims to bridge the gap between cosmetic ingredient science and consumer needs, providing personalized product safety information based on individual health profiles.
