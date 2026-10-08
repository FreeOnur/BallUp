plugins {
    alias(libs.plugins.ballup.kmp.library)
}

// Test doubles and helpers shared by all modules' tests (fakes, fixtures, rules).
kotlin {
    sourceSets {
        commonMain.dependencies {
            api(projects.shared.core.model)
            api(libs.kotlin.test)
            api(libs.kotlinx.coroutines.test)
            api(libs.turbine)
            api(libs.koin.test)
            api(libs.ktor.client.mock)
        }
    }
}
