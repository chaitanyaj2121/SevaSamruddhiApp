plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.setupfirebase"
    
    compileSdk = 34 // Set a valid compile SDK version
    
    defaultConfig {
        applicationId = "com.example.setupfirebase"
        minSdk = 21 // Set a valid minSdk version
        targetSdk = 34 // Set a valid targetSdk version
        versionCode = 1
        versionName = "1.0"
    }

   buildTypes {
    release {
        isMinifyEnabled = true  // ✅ Enables code shrinking (R8)
        isShrinkResources = true // ✅ Enables resource shrinking

        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
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
