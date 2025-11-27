/// Environment configuration for the Metanoia app
class Env {
  // Firebase configuration - these should be replaced with actual values
  // or loaded from flutter_dotenv in production
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  );
  
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );
  
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'metanoia-dev',
  );
  
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: '',
  );
  
  // API Backend
  // Production: Use Firebase Functions
  // Development: Use local server for faster iteration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/api',
  );
  
  // Helper to get the correct API URL based on environment
  static String getApiUrl() {
    // If custom API base URL is provided, use it
    if (apiBaseUrl != 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/api') {
      return apiBaseUrl;
    }
    
    // Use Firebase Functions by default (works without Mac connection)
    // Project: mindclon-dev, Region: europe-west2
    return 'https://europe-west2-mindclon-dev.cloudfunctions.net';
  }
  
  // Check if using Firebase Functions (callable functions)
  static bool get useFirebaseFunctions => 
      getApiUrl().contains('cloudfunctions.net');
  
  // Sentry
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  
  // Environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );
  
  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';
}



