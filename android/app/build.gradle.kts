plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
    id "dev.flutter.flutter-gradle-plugin"
}
android {
    namespace "com.example.Angles"
    compileSdkVersion 36

    defaultConfig {
        applicationId "com.example.Angles"
        minSdkVersion 24
        targetSdkVersion 36
        versionCode 1
        versionName "1.0.0"
    }

    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    ndkVersion "27.3.13750724"
}

flutter {
    source = "../.."
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7"
    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.0.4"
}