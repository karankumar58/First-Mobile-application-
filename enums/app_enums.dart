// enums/app_enums.dart

enum Gender { male, female, other, preferNotToSay }

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

enum AuthState { idle, loading, success, error }

enum Subject {
  mobileAppDevelopment,
  softwareReengineering,
  mis,
}

extension SubjectExtension on Subject {
  String get title {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Mobile App Development';
      case Subject.softwareReengineering:
        return 'Software Re-engineering';
      case Subject.mis:
        return 'MIS';
    }
  }

  String get description {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Learn to build cross-platform mobile applications using Flutter and Dart. '
            'Topics include UI design, state management, navigation, REST APIs, and deployment '
            'to both Android and iOS platforms.';
      case Subject.softwareReengineering:
        return 'Study the principles and techniques for restructuring existing software systems. '
            'Covers reverse engineering, refactoring, migration strategies, and modernizing '
            'legacy codebases to meet current standards.';
      case Subject.mis:
        return 'Management Information Systems covers the use of information technology in '
            'business processes. Topics include database management, ERP systems, decision '
            'support, and IT governance frameworks.';
    }
  }

  String get schedule {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Monday & Wednesday  |  10:00 AM – 11:30 AM  |  Room 301';
      case Subject.softwareReengineering:
        return 'Tuesday & Thursday  |  12:00 PM – 1:30 PM  |  Room 205';
      case Subject.mis:
        return 'Friday  |  9:00 AM – 12:00 PM  |  Room 410';
    }
  }

  String get iconEmoji {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return '📱';
      case Subject.softwareReengineering:
        return '🔧';
      case Subject.mis:
        return '📊';
    }
  }
}
