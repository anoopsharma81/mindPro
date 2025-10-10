/// User profile model aligned with Firestore schema
class Profile {
  final String uid;
  final String displayName;
  final String gmcNumber;
  final String defaultYear;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Profile({
    required this.uid,
    required this.displayName,
    required this.gmcNumber,
    required this.defaultYear,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Profile copyWith({
    String? displayName,
    String? gmcNumber,
    String? defaultYear,
    DateTime? updatedAt,
  }) => Profile(
    uid: uid,
    displayName: displayName ?? this.displayName,
    gmcNumber: gmcNumber ?? this.gmcNumber,
    defaultYear: defaultYear ?? this.defaultYear,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  
  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'gmcNumber': gmcNumber,
    'defaultYear': defaultYear,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  static Profile fromJson(String uid, Map<String, dynamic> json) => Profile(
    uid: uid,
    displayName: json['displayName'] as String? ?? '',
    gmcNumber: json['gmcNumber'] as String? ?? '',
    defaultYear: json['defaultYear'] as String? ?? DateTime.now().year.toString(),
    createdAt: json['createdAt'] != null 
      ? DateTime.parse(json['createdAt'] as String)
      : DateTime.now(),
    updatedAt: json['updatedAt'] != null
      ? DateTime.parse(json['updatedAt'] as String)
      : DateTime.now(),
  );
}

/// Year-specific appraisal configuration
class YearConfig {
  final String year;
  final String specialty;
  final String org;
  final String appraiserName;
  final String appraiserRole;
  final DateTime? appraisalDate;
  final String location;
  
  YearConfig({
    required this.year,
    required this.specialty,
    required this.org,
    required this.appraiserName,
    required this.appraiserRole,
    this.appraisalDate,
    required this.location,
  });
  
  YearConfig copyWith({
    String? specialty,
    String? org,
    String? appraiserName,
    String? appraiserRole,
    DateTime? appraisalDate,
    String? location,
  }) => YearConfig(
    year: year,
    specialty: specialty ?? this.specialty,
    org: org ?? this.org,
    appraiserName: appraiserName ?? this.appraiserName,
    appraiserRole: appraiserRole ?? this.appraiserRole,
    appraisalDate: appraisalDate ?? this.appraisalDate,
    location: location ?? this.location,
  );
  
  Map<String, dynamic> toJson() => {
    'specialty': specialty,
    'org': org,
    'appraiserName': appraiserName,
    'appraiserRole': appraiserRole,
    'appraisalDate': appraisalDate?.toIso8601String(),
    'location': location,
  };
  
  static YearConfig fromJson(String year, Map<String, dynamic> json) => YearConfig(
    year: year,
    specialty: json['specialty'] as String? ?? '',
    org: json['org'] as String? ?? '',
    appraiserName: json['appraiserName'] as String? ?? '',
    appraiserRole: json['appraiserRole'] as String? ?? '',
    appraisalDate: json['appraisalDate'] != null
      ? DateTime.parse(json['appraisalDate'] as String)
      : null,
    location: json['location'] as String? ?? '',
  );
}


