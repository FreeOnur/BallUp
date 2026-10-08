import app.ballup.buildlogic.assignBallupGroup
import app.ballup.buildlogic.ballupNamespace
import app.ballup.buildlogic.configureKotlinJvmTarget
import app.ballup.buildlogic.intVersion
import app.ballup.buildlogic.javaVersion
import app.ballup.buildlogic.lib
import app.ballup.buildlogic.libs
import com.android.build.api.dsl.LibraryExtension
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.configure
import org.gradle.kotlin.dsl.dependencies

/** Android library with Jetpack Compose – every Android UI module uses Compose. */
class AndroidLibraryConventionPlugin : Plugin<Project> {
    override fun apply(target: Project) = with(target) {
        pluginManager.apply("com.android.library")
        pluginManager.apply("org.jetbrains.kotlin.plugin.compose")
        assignBallupGroup()

        extensions.configure<LibraryExtension> {
            namespace = ballupNamespace()
            compileSdk = libs.intVersion("androidCompileSdk")
            defaultConfig {
                minSdk = libs.intVersion("androidMinSdk")
                testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
            }
            buildFeatures.compose = true
            compileOptions {
                sourceCompatibility = javaVersion
                targetCompatibility = javaVersion
            }
            testOptions.animationsDisabled = true
        }
        configureKotlinJvmTarget()

        dependencies {
            val bom = libs.lib("androidx-compose-bom")
            add("implementation", platform(bom))
            add("androidTestImplementation", platform(bom))
            add("implementation", libs.lib("androidx-compose-ui-tooling-preview"))
            add("debugImplementation", libs.lib("androidx-compose-ui-tooling"))
            add("testImplementation", libs.lib("kotlin-test"))
        }
    }
}
