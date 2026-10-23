plugins {
    alias(libs.plugins.ballup.kmp.library)
    alias(libs.plugins.sqldelight)
}

// Local offline-first cache on the device. The UI always reads from here; the server only refreshes it.
sqldelight {
    databases {
        create("BallUpDatabase") {
            packageName = "eu.ballup.shared.core.database"
            schemaOutputDirectory = file("src/commonMain/sqldelight/databases")
            verifyMigrations = true
        }
    }
}

kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(projects.shared.core.model)
            api(libs.sqldelight.runtime)
            implementation(libs.sqldelight.coroutines.extensions)
        }
        androidMain.dependencies {
            implementation(libs.sqldelight.android.driver)
        }
        iosMain.dependencies {
            implementation(libs.sqldelight.native.driver)
        }
    }
}
