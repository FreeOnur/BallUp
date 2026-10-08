import app.ballup.buildlogic.assignBallupGroup
import app.ballup.buildlogic.configureKotlinJvmTarget
import app.ballup.buildlogic.intVersion
import app.ballup.buildlogic.javaVersion
import app.ballup.buildlogic.lib
import app.ballup.buildlogic.libs
import com.android.build.api.dsl.ApplicationExtension
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.configure
import org.gradle.kotlin.dsl.dependencies

class AndroidApplicationConventionPlugin : Plugin<Project> {
    override fun apply(target: Project) = with(target) {
        pluginManager.apply("com.android.application")
        pluginManager.apply("org.jetbrains.kotlin.plugin.compose")
        assignBallupGroup()

        extensions.configure<ApplicationExtension> {
            compileSdk = libs.intVersion("androidCompileSdk")
            defaultConfig {
                minSdk = libs.intVersion("androidMinSdk")
                targetSdk = libs.intVersion("androidTargetSdk")
            }
            buildFeatures {
                compose = true
                buildConfig = true
            }
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
        }
    }
}
