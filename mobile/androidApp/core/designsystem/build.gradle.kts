plugins {
    alias(libs.plugins.ballup.android.library)
}

// BallUp design system: theme, tokens, components, motion (animation specs).
dependencies {
    api(libs.androidx.compose.ui)
    api(libs.androidx.compose.foundation)
    api(libs.androidx.compose.animation)
    api(libs.androidx.compose.material3)
}
