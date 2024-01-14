const ITERATIONS = 10000;
const HASH_LENGTH = 256;

const appThemeMode = "APP_THEME_MODE";

String baseUrl = const String.fromEnvironment(
  "BASE_URL",
  // defaultValue: "https://camouflage.43.204.229.12.nip.io",
  defaultValue: "http://192.168.1.2:3000",
);
