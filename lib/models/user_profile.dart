import 'dart:core';

class UserProfile {
  // Physiological
  final int? age;
  final String? gender;
  final double? weight;
  final double? height;

  // Skin type
  final String? skinType;
  final bool? sensitiveSkin;
  final bool? atopicSkin;
  final bool? acneProne;

  // Allergies
  final bool? hasAllergies;
  final List<String>? cosmeticAllergies;
  final List<String>? generalAllergies;

  // Dermatological conditions (existing)
  final bool? acneVulgaris;
  final bool? psoriasis;
  final bool? eczema;
  final bool? rosacea;

  // Additional skin conditions
  final bool? barrierDysfunction;
  final bool? seborrheicDermatitis;
  final bool? periorbitalDermatitis;
  final bool? contactDermatitis;
  final bool? keratinizationDisorders;

  // Medications (detailed)
  final List<String>? photosensitizingMedications;
  final List<String>? diureticMedications;
  final bool? retinoidTherapy;
  final String? corticosteroidUse; // "topical", "systemic", "both"
  final List<String>? immunosuppressants;
  final String? hormonalTherapy; // "birth_control", "hrt", "other"
  final String? otherMedications;
  final String? medicalProcedures;

  // Legacy (backward compatibility)
  final bool? photosensitizingDrugs;
  final bool? diuretics;

  // Lifestyle
  final String? smoking;
  final int? stressLevel;
  final String? tanning;
  final bool? pregnancy;

  // Cosmetic exposure patterns (for HED calculations)
  final String? productUsageFrequency; // "daily", "weekly", "occasionally"
  final List<String>? typicalApplicationAreas; // ["face", "body", "hands"]
  final double? bodyBackgroundExposure; // BSA in m²
  final List<String>? preferredProductTypes; // ["leave-on", "rinse-off"]

  // Ingredient safety history (blacklist)
  final List<String>? knownIntolerances;
  final List<Map<String, dynamic>>? previousAdverseReactions;
  final List<String>? dermatologistRecommendedAvoid;

  // User preferences
  final bool? preferNatural;
  final bool? veganOnly;
  final bool? fragranceFree;
  final List<String>? avoidCategories; // ["parabens", "sulfates"]
  final List<String>? certificationPreferences; // ["ecocert", "cosmos"]

  // Environmental factors
  final String? climateType; // "dry", "humid", "temperate", "cold"
  final String? pollutionExposure; // "high", "moderate", "low"
  final String? sunExposure; // "high_outdoor", "moderate", "minimal_indoor"
  final String? waterHardness; // "hard", "soft", "moderate"

  // Cosmetic goals
  final List<String>? primaryConcerns; // ["anti_aging", "acne", "hydration"]

  UserProfile({
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.skinType,
    this.sensitiveSkin,
    this.atopicSkin,
    this.acneProne,
    this.hasAllergies,
    this.cosmeticAllergies,
    this.generalAllergies,
    this.acneVulgaris,
    this.psoriasis,
    this.eczema,
    this.rosacea,
    this.barrierDysfunction,
    this.seborrheicDermatitis,
    this.periorbitalDermatitis,
    this.contactDermatitis,
    this.keratinizationDisorders,
    this.photosensitizingMedications,
    this.diureticMedications,
    this.retinoidTherapy,
    this.corticosteroidUse,
    this.immunosuppressants,
    this.hormonalTherapy,
    this.otherMedications,
    this.medicalProcedures,
    this.photosensitizingDrugs,
    this.diuretics,
    this.smoking,
    this.stressLevel,
    this.tanning,
    this.pregnancy,
    this.productUsageFrequency,
    this.typicalApplicationAreas,
    this.bodyBackgroundExposure,
    this.preferredProductTypes,
    this.knownIntolerances,
    this.previousAdverseReactions,
    this.dermatologistRecommendedAvoid,
    this.preferNatural,
    this.veganOnly,
    this.fragranceFree,
    this.avoidCategories,
    this.certificationPreferences,
    this.climateType,
    this.pollutionExposure,
    this.sunExposure,
    this.waterHardness,
    this.primaryConcerns,
  });

  Map<String, dynamic> toJson() => {
    'age': age,
    'gender': gender,
    'weight': weight,
    'height': height,
    'skinType': skinType,
    'sensitiveSkin': sensitiveSkin,
    'atopicSkin': atopicSkin,
    'acneProne': acneProne,
    'hasAllergies': hasAllergies,
    'cosmeticAllergies': cosmeticAllergies,
    'generalAllergies': generalAllergies,
    'acneVulgaris': acneVulgaris,
    'psoriasis': psoriasis,
    'eczema': eczema,
    'rosacea': rosacea,
    'barrierDysfunction': barrierDysfunction,
    'seborrheicDermatitis': seborrheicDermatitis,
    'periorbitalDermatitis': periorbitalDermatitis,
    'contactDermatitis': contactDermatitis,
    'keratinizationDisorders': keratinizationDisorders,
    'photosensitizingMedications': photosensitizingMedications,
    'diureticMedications': diureticMedications,
    'retinoidTherapy': retinoidTherapy,
    'corticosteroidUse': corticosteroidUse,
    'immunosuppressants': immunosuppressants,
    'hormonalTherapy': hormonalTherapy,
    'otherMedications': otherMedications,
    'medicalProcedures': medicalProcedures,
    'photosensitizingDrugs': photosensitizingDrugs,
    'diuretics': diuretics,
    'smoking': smoking,
    'stressLevel': stressLevel,
    'tanning': tanning,
    'pregnancy': pregnancy,
    'productUsageFrequency': productUsageFrequency,
    'typicalApplicationAreas': typicalApplicationAreas,
    'bodyBackgroundExposure': bodyBackgroundExposure,
    'preferredProductTypes': preferredProductTypes,
    'knownIntolerances': knownIntolerances,
    'previousAdverseReactions': previousAdverseReactions,
    'dermatologistRecommendedAvoid': dermatologistRecommendedAvoid,
    'preferNatural': preferNatural,
    'veganOnly': veganOnly,
    'fragranceFree': fragranceFree,
    'avoidCategories': avoidCategories,
    'certificationPreferences': certificationPreferences,
    'climateType': climateType,
    'pollutionExposure': pollutionExposure,
    'sunExposure': sunExposure,
    'waterHardness': waterHardness,
    'primaryConcerns': primaryConcerns,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'],
      gender: json['gender'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      skinType: json['skinType'],
      sensitiveSkin: json['sensitiveSkin'],
      atopicSkin: json['atopicSkin'],
      acneProne: json['acneProne'],
      hasAllergies: json['hasAllergies'],
      cosmeticAllergies: json['cosmeticAllergies'] != null
          ? List<String>.from(json['cosmeticAllergies'])
          : null,
      generalAllergies: json['generalAllergies'] != null
          ? List<String>.from(json['generalAllergies'])
          : null,
      acneVulgaris: json['acneVulgaris'],
      psoriasis: json['psoriasis'],
      eczema: json['eczema'],
      rosacea: json['rosacea'],
      barrierDysfunction: json['barrierDysfunction'],
      seborrheicDermatitis: json['seborrheicDermatitis'],
      periorbitalDermatitis: json['periorbitalDermatitis'],
      contactDermatitis: json['contactDermatitis'],
      keratinizationDisorders: json['keratinizationDisorders'],
      photosensitizingMedications: json['photosensitizingMedications'] != null
          ? List<String>.from(json['photosensitizingMedications'])
          : null,
      diureticMedications: json['diureticMedications'] != null
          ? List<String>.from(json['diureticMedications'])
          : null,
      retinoidTherapy: json['retinoidTherapy'],
      corticosteroidUse: json['corticosteroidUse'],
      immunosuppressants: json['immunosuppressants'] != null
          ? List<String>.from(json['immunosuppressants'])
          : null,
      hormonalTherapy: json['hormonalTherapy'],
      otherMedications: json['otherMedications'],
      medicalProcedures: json['medicalProcedures'],
      photosensitizingDrugs: json['photosensitizingDrugs'],
      diuretics: json['diuretics'],
      smoking: json['smoking'],
      stressLevel: json['stressLevel'],
      tanning: json['tanning'],
      pregnancy: json['pregnancy'],
      productUsageFrequency: json['productUsageFrequency'],
      typicalApplicationAreas: json['typicalApplicationAreas'] != null
          ? List<String>.from(json['typicalApplicationAreas'])
          : null,
      bodyBackgroundExposure: json['bodyBackgroundExposure']?.toDouble(),
      preferredProductTypes: json['preferredProductTypes'] != null
          ? List<String>.from(json['preferredProductTypes'])
          : null,
      knownIntolerances: json['knownIntolerances'] != null
          ? List<String>.from(json['knownIntolerances'])
          : null,
      previousAdverseReactions: json['previousAdverseReactions'] != null
          ? List<Map<String, dynamic>>.from(json['previousAdverseReactions'])
          : null,
      dermatologistRecommendedAvoid: json['dermatologistRecommendedAvoid'] != null
          ? List<String>.from(json['dermatologistRecommendedAvoid'])
          : null,
      preferNatural: json['preferNatural'],
      veganOnly: json['veganOnly'],
      fragranceFree: json['fragranceFree'],
      avoidCategories: json['avoidCategories'] != null
          ? List<String>.from(json['avoidCategories'])
          : null,
      certificationPreferences: json['certificationPreferences'] != null
          ? List<String>.from(json['certificationPreferences'])
          : null,
      climateType: json['climateType'],
      pollutionExposure: json['pollutionExposure'],
      sunExposure: json['sunExposure'],
      waterHardness: json['waterHardness'],
      primaryConcerns: json['primaryConcerns'] != null
          ? List<String>.from(json['primaryConcerns'])
          : null,
    );
  }
}