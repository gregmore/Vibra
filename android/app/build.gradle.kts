import java.util.Properties
import java.security.KeyStore
import java.security.cert.X509Certificate

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Native Firebase configuration stays local; CI can compile without it.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.vibra.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.vibra.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["spotifyRedirectScheme"] = "com.vibra.app"
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
}

// Store artifacts must never fall back to the debug certificate.
tasks.configureEach {
    if (name in listOf("validateSigningRelease", "signReleaseBundle", "packageRelease")) {
        doFirst {
            val requiredKeys = listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
            val missingKeys = requiredKeys.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
            if (!keystorePropertiesFile.exists() || missingKeys.isNotEmpty()) {
                throw GradleException("Release signing requires android/key.properties and a real upload keystore. See RELEASE.md.")
            }
            val releaseStore = file(keystoreProperties.getProperty("storeFile"))
            if (!releaseStore.isFile) {
                throw GradleException("Release upload keystore does not exist. See RELEASE.md.")
            }
            if (releaseStore.name == "debug.keystore" || keystoreProperties.getProperty("keyAlias") == "androiddebugkey") {
                throw GradleException("The Android debug key cannot sign a store release.")
            }
            val store = try {
                KeyStore.getInstance(releaseStore, keystoreProperties.getProperty("storePassword").toCharArray())
            } catch (error: Exception) {
                throw GradleException("Cannot open the release upload keystore. Check android/key.properties.")
            }
            val certificate = store.getCertificate(keystoreProperties.getProperty("keyAlias")) as? X509Certificate
                ?: throw GradleException("Release key alias does not have a signing certificate.")
            if (certificate.subjectX500Principal.name.contains("CN=Android Debug", ignoreCase = true)) {
                throw GradleException("The Android debug certificate cannot sign a store release.")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
