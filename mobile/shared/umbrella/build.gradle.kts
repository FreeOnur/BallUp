plugins {
    alias(libs.plugins.kotlin.multiplatform)
}

// Bundles all shared modules into ONE iOS framework "Shared" (import Shared in Swift).
// Xcode builds it via `:shared:umbrella:embedAndSignAppleFrameworkForXcode` (see iosApp/project.yml).
val exported = listOf(
    projects.shared.core.model,
    projects.shared.core.common,
    projects.shared.core.domain,
    projects.shared.core.data,
    projects.shared.core.config,
    projects.shared.core.telemetry,
    projects.shared.feature.auth,
    projects.shared.feature.me,
    projects.shared.feature.profiles,
    projects.shared.feature.home,
    projects.shared.feature.courts,
    projects.shared.feature.uploads,
    projects.shared.feature.games,
    projects.shared.feature.matchmaking,
    projects.shared.feature.rankings,
    projects.shared.feature.teams,
    projects.shared.feature.tournaments,
    projects.shared.feature.clans,
    projects.shared.feature.social,
    projects.shared.feature.chat,
    projects.shared.feature.community,
    projects.shared.feature.notifications,
    projects.shared.feature.training,
    projects.shared.feature.camera,
    projects.shared.feature.gamification,
    projects.shared.feature.reports,
    projects.shared.feature.subscriptions,
)

group = "eu.ballup.shared"

kotlin {
    listOf(iosArm64(), iosSimulatorArm64()).forEach { target ->
        target.binaries.framework {
            baseName = "Shared"
            isStatic = true
            exported.forEach { export(it) }
        }
    }

    sourceSets {
        commonMain.dependencies {
            exported.forEach { api(it) }
        }
    }
}
