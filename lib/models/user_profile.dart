import 'dart:core';

class UserProfile {
  // physiological
  final int? age;
  final String? gender;
  final double? weight;
  final double? height;

  //skin type
  final String? skinType;
  final bool? sensitiveSkin;
  final bool? atopicSkin;
  final bool? acneProne;

  //allergies
  final bool? hasAllergies;
  final List<String>? cosmeticAllergies;
  final List<String>? generalAllergies;

  //dermatological conditions
  final bool? acneVulgaris; //trądzik pospolity
  final bool? psoriasis; //łuszczyca
  final bool? eczema; //egzema
  final bool? rosacea; //trądzik różowaty

  //medications
  final bool? photosensitizingDrugs; //leki fotouczulające  // raczej jako lista
  final bool? diuretics; //leki moczopędne   // raczej jako lista/String
  final String? otherMedications; //inne leki
  final String? medicalProcedures; //inne zabiegi

  //lifestyle
  final String? smoking; // 6 stages
  final int? stressLevel; // 0-10
  final String? tanning; //nadmierne opalanie - 6 stages
  final bool? pregnancy;


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
    this.photosensitizingDrugs,
    this.diuretics,
    this.otherMedications,
    this.medicalProcedures,
    this.smoking,
    this.stressLevel,
    this.tanning,
    this.pregnancy
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
    'photosensitizingDrugs': photosensitizingDrugs,
    'diuretics': diuretics,
    'otherMedications': otherMedications,
    'medicalProcedures': medicalProcedures,
    'smoking': smoking,
    'stressLevel': stressLevel,
    'tanning': tanning,
    'pregnancy': pregnancy,
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
      cosmeticAllergies: json['cosmeticAllergies'] != null ?
      List<String>.from(json['cosmeticAllergies']) : null,
      generalAllergies: json['generalAllergies'] != null ?
      List<String>.from(json['generalAllergies']) : null,
      acneVulgaris: json['acneVulgaris'],
      psoriasis: json['psoriasis'],
      eczema: json['eczema'],
      rosacea: json['rosacea'],
      photosensitizingDrugs: json['photosensitizingDrugs'],
      diuretics: json['diuretics'],
      otherMedications: json['otherMedications'],
      medicalProcedures: json['medicalProcedures'],
      smoking: json['smoking'],
      stressLevel: json['stressLevel'],
      tanning: json['tanning'],
      pregnancy: json['pregnancy'],
    );
  }

}