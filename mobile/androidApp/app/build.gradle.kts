plugins {
    alias(libs.plugins.ballup.android.application)
}

android {
    namespace = "app.ballup"

    defaultConfig {
        applicationId = "app.ballup"
        versionCode = 1
        versionName = "0.1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation(projects.androidApp.core.designsystem)
    implementation(projects.androidApp.core.ui)

    implementation(projects.androidApp.feature.auth)
    implementation(projects.androidApp.feature.me)
    implementation(projects.androidApp.feature.profiles)
    implementation(projects.androidApp.feature.home)
    implementation(projects.androidApp.feature.courts)
    implementation(projects.androidApp.feature.uploads)
    implementation(projects.androidApp.feature.games)
    implementation(projects.androidApp.feature.matchmaking)
    implementation(projects.androidApp.feature.rankings)
    implementation(projects.androidApp.feature.teams)
    implementation(projects.androidApp.feature.tournaments)
    implementation(projects.androidApp.feature.clans)
    implementation(projects.androidApp.feature.social)
    implementation(projects.androidApp.feature.chat)
    implementation(projects.androidApp.feature.community)
    implementation(projects.androidApp.feature.notifications)
    implementation(projects.androidApp.feature.training)
    implementation(projects.androidApp.feature.camera)
    implementation(projects.androidApp.feature.gamification)
    implementation(projects.androidApp.feature.reports)
    implementation(projects.androidApp.feature.subscriptions)

    implementation(projects.shared.core.data)
    implementation(projects.shared.core.config)
    implementation(projects.shared.core.telemetry)

    implementation(platform(libs.koin.bom))
    implementation(libs.koin.android)
    implementation(libs.koin.compose.viewmodel)
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.core.splashscreen)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.navigation3.runtime)
    implementation(libs.androidx.navigation3.ui)

    testImplementation(projects.shared.core.testing)
}
