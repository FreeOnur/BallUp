pluginManagement {
    includeBuild("build-logic")
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode = RepositoriesMode.FAIL_ON_PROJECT_REPOS
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
    }
}

rootProject.name = "ballup"
enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

// Same names as the backend modules. telemetry + config live only in shared/core (no UI).
val features = listOf(
    "auth",
    "me",
    "profiles",
    "home",
    "courts",
    "uploads",
    "games",
    "matchmaking",
    "rankings",
    "teams",
    "tournaments",
    "clans",
    "social",
    "chat",
    "community",
    "notifications",
    "training",
    "camera",
    "gamification",
    "reports",
    "subscriptions",
)

// Kotlin Multiplatform: data + domain, shared by Android and iOS
include(":shared:umbrella")
listOf("model", "common", "network", "database", "data", "domain", "testing", "telemetry", "config")
    .forEach { include(":shared:core:$it") }
features.forEach { include(":shared:feature:$it") }

// Android: Compose UI + ViewModels
include(":androidApp:app")
include(":androidApp:core:designsystem")
include(":androidApp:core:ui")
features.forEach { include(":androidApp:feature:$it") }
