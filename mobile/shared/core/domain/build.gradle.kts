plugins {
    alias(libs.plugins.ballup.kmp.library)
}

kotlin {
    sourceSets {
        commonMain.dependencies {
            api(projects.shared.core.model)
            api(projects.shared.core.common)
        }
    }
}
