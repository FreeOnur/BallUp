plugins {
    alias(libs.plugins.ballup.kmp.library)
}

// Own crash reporting + analytics, sent to the self-hosted backend. No third-party SDKs.
kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(projects.shared.core.common)
            implementation(projects.shared.core.network)
            implementation(projects.shared.core.database)
        }
    }
}
