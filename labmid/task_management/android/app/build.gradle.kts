plugins {
    // 1. Apply necessary Gradle plugins
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 2. Set Android project configuration
    namespace = "com.example.task_management"
    // Use Flutter's SDK version defined in flutter.gradle
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Set Java compatibility version
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable desugaring for newer Java features on older Android versions
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Set JVM target for Kotlin compilation
        jvmTarget = "17"
    }

    defaultConfig {
        // 3. Define app specific configurations
        applicationId = "com.example.task_management"
        minSdk = flutter.minSdkVersion

        // FIX APPLIED HERE: targetSdk property ko set karne ke liye '=' (equals) sign use karein
        // FIX: Hardcoded targetSdk to 34 to ensure USE_EXACT_ALARM is handled correctly
        targetSdk = 34 // <-- CORRECTED LINE (Error fixed by adding '=')

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use debug signing config for release builds (usually temporary for development)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    // 4. Link to Flutter project root
    source = "../.."
}

dependencies {
    // 5. Define external dependencies
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    // Desugaring library dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}