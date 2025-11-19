// File: android/app/build.gradle.kts

plugins {
    id("com.android.application")
    kotlin("android") version "1.8.22"
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.task_management"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.task_management"
        minSdk = flutter.minSdkVersion                    // Flutter 3.38.1 default minSdk
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
        }
        debug {
            isMinifyEnabled = false
        }
    }

    // Optional: Enable view binding if you use Android views
    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."  // Path to your Flutter module
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
