plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Load keystore properties from key.properties file
val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
         load(FileInputStream(keystorePropertiesFile))
    }
}

fun signingProperty(name: String): String? =
    keystoreProperties.getProperty(name)?.takeIf { it.isNotBlank() }

val hasReleaseSigningConfig =
    listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
        .all { signingProperty(it) != null }

android {
    namespace = "com.diems.sevasamruddhi"
    
    compileSdk = 34 // Set a valid compile SDK version
    
    defaultConfig {
        applicationId = "com.diems.sevasamruddhi"
        minSdk = flutter.minSdkVersion // Set a valid minSdk version
        targetSdk = 34 // Set a valid targetSdk version
        versionCode = 1
        versionName = "1.0"
    }

    // Configure signing using the properties loaded above
    signingConfigs {
        if (hasReleaseSigningConfig) {
            create("release") {
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
                storeFile = file(signingProperty("storeFile")!!)
                storePassword = signingProperty("storePassword")
            }
        }
    }
    
    buildTypes {
        release {
            isMinifyEnabled = false  // ✅ Enables code shrinking (R8)
            isShrinkResources = false // ✅ Enables resource shrinking

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Use the release signing configuration when android/key.properties is present.
            if (hasReleaseSigningConfig) {
                signingConfig = signingConfigs.getByName("release")
            }
        }

        debug {
            isMinifyEnabled = false  // Debug builds should not shrink code
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    ndkVersion = "27.0.12077973"
}

flutter {
    source = "../.."
}
