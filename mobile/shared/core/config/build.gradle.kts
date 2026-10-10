plugins {
    alias(libs.plugins.ballup.kmp.library)
}

// Remote config + feature flags, served by the backend `config` module and cached locally.
kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(projects.shared.core.common)
            implementation(projects.shared.core.network)
            implementation(projects.shared.core.database)
        }
    }
}
