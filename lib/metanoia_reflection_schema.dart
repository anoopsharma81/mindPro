/// lib/metanoia_reflection_schema.dart
///
/// Metanoia Reflection Schema + PRES Example
///
/// This file defines the data model Metanoia uses for structured reflections:
/// - patternRecognition
/// - analyticalReasoning
/// - biasFiltering
/// - learning (encoding / prediction / update)
/// - retrievalPlan (6 weeks / 6 months / 12 months)
///
/// You can:
/// - Plug this into your persistence layer (Firestore / SQLite / API).
/// - Build Reflection UI screens around these fields.
/// - Seed the app with the PRES example below as a template.

import 'dart:convert';

class MetanoiaReflection {
  final String id; // e.g. UUID or Firestore doc id
  final String caseTitle; // Short title: "Headache that turned out to be PRES"
  final String caseDescription; // Free text description of the case

  final PatternRecognition patternRecognition;
  final AnalyticalReasoning analyticalReasoning;
  final BiasFiltering biasFiltering;
  final LearningBlock learning;
  final RetrievalPlan retrievalPlan;

  // Optional metadata
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? author; // e.g. "Dr Govind Chavada"
  final String? domain; // e.g. "Neurology", "Shipping", "Aviation"

  MetanoiaReflection({
    required this.id,
    required this.caseTitle,
    required this.caseDescription,
    required this.patternRecognition,
    required this.analyticalReasoning,
    required this.biasFiltering,
    required this.learning,
    required this.retrievalPlan,
    required this.createdAt,
    this.updatedAt,
    this.author,
    this.domain,
  });

  MetanoiaReflection copyWith({
    String? id,
    String? caseTitle,
    String? caseDescription,
    PatternRecognition? patternRecognition,
    AnalyticalReasoning? analyticalReasoning,
    BiasFiltering? biasFiltering,
    LearningBlock? learning,
    RetrievalPlan? retrievalPlan,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? author,
    String? domain,
  }) {
    return MetanoiaReflection(
      id: id ?? this.id,
      caseTitle: caseTitle ?? this.caseTitle,
      caseDescription: caseDescription ?? this.caseDescription,
      patternRecognition: patternRecognition ?? this.patternRecognition,
      analyticalReasoning: analyticalReasoning ?? this.analyticalReasoning,
      biasFiltering: biasFiltering ?? this.biasFiltering,
      learning: learning ?? this.learning,
      retrievalPlan: retrievalPlan ?? this.retrievalPlan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      domain: domain ?? this.domain,
    );
  }

  factory MetanoiaReflection.fromJson(Map<String, dynamic> json) {
    return MetanoiaReflection(
      id: json['id'] as String,
      caseTitle: json['caseTitle'] as String,
      caseDescription: json['caseDescription'] as String,
      patternRecognition: PatternRecognition.fromJson(
        json['patternRecognition'] as Map<String, dynamic>,
      ),
      analyticalReasoning: AnalyticalReasoning.fromJson(
        json['analyticalReasoning'] as Map<String, dynamic>,
      ),
      biasFiltering: BiasFiltering.fromJson(
        json['biasFiltering'] as Map<String, dynamic>,
      ),
      learning: LearningBlock.fromJson(
        json['learning'] as Map<String, dynamic>,
      ),
      retrievalPlan: RetrievalPlan.fromJson(
        json['retrievalPlan'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      author: json['author'] as String?,
      domain: json['domain'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseTitle': caseTitle,
      'caseDescription': caseDescription,
      'patternRecognition': patternRecognition.toJson(),
      'analyticalReasoning': analyticalReasoning.toJson(),
      'biasFiltering': biasFiltering.toJson(),
      'learning': learning.toJson(),
      'retrievalPlan': retrievalPlan.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'author': author,
      'domain': domain,
    };
  }
}

class PatternRecognition {
  final List<String> keyFeatures;
  final String prototype; // e.g. the "if pattern then…" mental shortcut

  PatternRecognition({
    required this.keyFeatures,
    required this.prototype,
  });

  factory PatternRecognition.fromJson(Map<String, dynamic> json) {
    return PatternRecognition(
      keyFeatures:
          (json['keyFeatures'] as List<dynamic>).map((e) => e as String).toList(),
      prototype: json['prototype'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyFeatures': keyFeatures,
      'prototype': prototype,
    };
  }
}

class AnalyticalReasoning {
  final List<String> initialDifferential;
  final List<String> discriminatorsForDiagnosis;
  final List<String> managementLogic;

  AnalyticalReasoning({
    required this.initialDifferential,
    required this.discriminatorsForDiagnosis,
    required this.managementLogic,
  });

  factory AnalyticalReasoning.fromJson(Map<String, dynamic> json) {
    return AnalyticalReasoning(
      initialDifferential: (json['initialDifferential'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      discriminatorsForDiagnosis:
          (json['discriminatorsForDiagnosis'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      managementLogic: (json['managementLogic'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initialDifferential': initialDifferential,
      'discriminatorsForDiagnosis': discriminatorsForDiagnosis,
      'managementLogic': managementLogic,
    };
  }
}

class BiasFiltering {
  final List<String> identifiedBiases;
  final List<String> correctiveRules;

  BiasFiltering({
    required this.identifiedBiases,
    required this.correctiveRules,
  });

  factory BiasFiltering.fromJson(Map<String, dynamic> json) {
    return BiasFiltering(
      identifiedBiases: (json['identifiedBiases'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctiveRules: (json['correctiveRules'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifiedBiases': identifiedBiases,
      'correctiveRules': correctiveRules,
    };
  }
}

class LearningBlock {
  final String encoding; // What I want to store.
  final String prediction; // How I want to behave next time.
  final String update; // How my mental model changes.

  LearningBlock({
    required this.encoding,
    required this.prediction,
    required this.update,
  });

  factory LearningBlock.fromJson(Map<String, dynamic> json) {
    return LearningBlock(
      encoding: json['encoding'] as String,
      prediction: json['prediction'] as String,
      update: json['update'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encoding': encoding,
      'prediction': prediction,
      'update': update,
    };
  }
}

class RetrievalPlan {
  final String sixWeeks;
  final String sixMonths;
  final String twelveMonths;

  RetrievalPlan({
    required this.sixWeeks,
    required this.sixMonths,
    required this.twelveMonths,
  });

  factory RetrievalPlan.fromJson(Map<String, dynamic> json) {
    return RetrievalPlan(
      sixWeeks: json['6_weeks'] as String,
      sixMonths: json['6_months'] as String,
      twelveMonths: json['12_months'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '6_weeks': sixWeeks,
      '6_months': sixMonths,
      '12_months': twelveMonths,
    };
  }
}

/// ---------------------------------------------------------------------------
/// PRES EXAMPLE: You can use this as a seed/template in the app
/// ---------------------------------------------------------------------------

Map<String, dynamic> presReflectionJson() => {
      "id": "pres-headache-example-1",
      "caseTitle": "Headache that turned out to be PRES",
      "caseDescription":
          "A patient presented with acute headache and non-specific neurological symptoms, initially managed as a primary headache. Subsequent deterioration and MRI revealed posterior reversible encephalopathy syndrome (PRES) with typical parieto-occipital vasogenic oedema. Triggers included poorly controlled blood pressure and systemic illness/medication factors.",
      "patternRecognition": {
        "keyFeatures": [
          "Headache with visual disturbance, confusion or reduced alertness, and/or seizures",
          "Significant or labile hypertension",
          "Context of eclampsia, renal failure, sepsis, or immunosuppressive/chemotherapy drugs"
        ],
        "prototype":
            "Headache + visual symptoms + altered mental state ± seizures in a hypertensive or medically fragile patient → think PRES."
      },
      "analyticalReasoning": {
        "initialDifferential": [
          "Primary headache (migraine ± aura)",
          "Subarachnoid haemorrhage",
          "Intracerebral haemorrhage / hypertensive encephalopathy",
          "Cerebral venous sinus thrombosis",
          "Infective or autoimmune encephalitis",
          "Metabolic/toxic encephalopathy"
        ],
        "discriminatorsForDiagnosis": [
          "Combination of headache, visual disturbance, encephalopathy and/or seizures",
          "Marked hypertension or endothelial stressor (eclampsia, renal failure, sepsis, immunosuppressants/chemotherapy)",
          "MRI brain (T2/FLAIR): symmetrical parieto-occipital vasogenic oedema, sometimes extending to frontal, cerebellar or deep structures"
        ],
        "managementLogic": [
          "Rapid blood pressure control and optimisation",
          "Treat or remove the underlying trigger (renal failure, drugs, eclampsia, sepsis)",
          "Seizure control and high-dependency monitoring",
          "Avoid further endothelial-toxic or vasoactive drugs where possible",
          "Repeat imaging if clinical course is atypical or severe"
        ]
      },
      "biasFiltering": {
        "identifiedBiases": [
          "Anchoring on migraine or primary headache because of age or past labels",
          "Search satisficing after settling on a plausible benign headache diagnosis",
          "False reassurance from a normal CT head in the presence of clear red flags",
          "Low availability of PRES as a mental template compared with SAH/migraine"
        ],
        "correctiveRules": [
          "In any hypertensive or high-risk patient with headache + visual symptoms + encephalopathy ± seizures, explicitly add PRES to the differential.",
          "Treat severe or labile hypertension as a central clue when CNS symptoms are evolving, not as background noise.",
          "Normal CT head in a red-flag headache should trigger escalation to MRI with PRES in the clinical question, not diagnostic closure."
        ]
      },
      "learning": {
        "encoding":
            "In high-risk, hypertensive or systemically unwell patients, headache + visual disturbance + altered mental state or seizures should always trigger a PRES check and urgent MRI consideration.",
        "prediction":
            "Next time I see this pattern, I will explicitly consider PRES, document it in the differential, escalate to MRI with PRES in the clinical question, and optimise blood pressure early.",
        "update":
            "PRES is now a standard red-flag consideration in secondary headache with hypertension and cortical symptoms, not a rare zebra."
      },
      "retrievalPlan": {
        "6_weeks":
            "Recall the PRES case and identify the earliest subtle clues (blood pressure, visual symptoms, mild confusion) that should raise suspicion before seizures or dramatic deterioration.",
        "6_months":
            "Review similar cases over the past 6 months and check whether I considered PRES explicitly, documented it, and obtained MRI promptly where appropriate.",
        "12_months":
            "Review a year's practice to see whether early recognition of PRES has improved and whether my thresholds for MRI and blood pressure control have appropriately shifted."
      },
      "createdAt": DateTime.now().toIso8601String(),
      "updatedAt": null,
      "author": "Dr Govind Chavada",
      "domain": "Neurology"
    };

/// Helper to get pretty-printed JSON (useful for seeding files or debugging).
String prettyPrintPresReflectionJson() {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(presReflectionJson());
}

