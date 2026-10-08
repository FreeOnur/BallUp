plugins {
    alias(libs.plugins.ballup.android.library)
}

// Reusable UI built on domain models (e.g. court card, player avatar) shared across features.
dependencies {
    api(projects.androidApp.core.designsystem)
    api(projects.shared.core.model)
}
