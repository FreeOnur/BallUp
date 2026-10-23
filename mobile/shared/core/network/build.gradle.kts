plugins {
    alias(libs.plugins.ballup.kmp.library)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.openapi.generator)
}

// API client generated from the backend's OpenAPI contract (contracts/openapi.json).
// Run `./gradlew :shared:core:network:openApiGenerate` after the contract changes.
openApiGenerate {
    generatorName = "kotlin"
    library = "multiplatform"
    inputSpec = rootProject.layout.projectDirectory.file("../contracts/openapi.json")
    outputDir = layout.buildDirectory.dir("generated/openapi")
    packageName = "eu.ballup.shared.core.network.generated"
    configOptions.put("dateLibrary", "kotlinx-datetime")
    configOptions.put("enumPropertyNaming", "UPPERCASE")
}

kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(projects.shared.core.model)
            implementation(projects.shared.core.common)
            implementation(libs.ktor.client.core)
            implementation(libs.ktor.client.auth)
            implementation(libs.ktor.client.content.negotiation)
            implementation(libs.ktor.client.logging)
            implementation(libs.ktor.serialization.kotlinx.json)
        }
        androidMain.dependencies {
            implementation(libs.ktor.client.okhttp)
        }
        iosMain.dependencies {
            implementation(libs.ktor.client.darwin)
        }
        commonTest.dependencies {
            implementation(libs.ktor.client.mock)
        }
    }
}
