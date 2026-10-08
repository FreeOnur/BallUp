import app.ballup.buildlogic.assignBallupGroup
import app.ballup.buildlogic.ballupNamespace
import app.ballup.buildlogic.intVersion
import app.ballup.buildlogic.lib
import app.ballup.buildlogic.libs
import com.android.build.api.dsl.KotlinMultiplatformAndroidLibraryTarget
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.plugins.ExtensionAware
import org.gradle.kotlin.dsl.configure
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinMultiplatformExtension

/** Kotlin Multiplatform library (data + domain) for Android and iOS. No UI. */
class KmpLibraryConventionPlugin : Plugin<Project> {
    override fun apply(target: Project) = with(target) {
        pluginManager.apply("org.jetbrains.kotlin.multiplatform")
        pluginManager.apply("com.android.kotlin.multiplatform.library")
        assignBallupGroup()

        extensions.configure<KotlinMultiplatformExtension> {
            (this as ExtensionAware).extensions.configure<KotlinMultiplatformAndroidLibraryTarget>("android") {
                namespace = ballupNamespace()
                compileSdk = libs.intVersion("androidCompileSdk")
                minSdk = libs.intVersion("androidMinSdk")
                withHostTest {}
                compilerOptions.jvmTarget.set(
                    JvmTarget.fromTarget(libs.findVersion("jvmTarget").get().requiredVersion),
                )
            }

            iosArm64()
            iosSimulatorArm64()

            applyDefaultHierarchyTemplate()

            sourceSets.getByName("commonMain").dependencies {
                api(project.dependencies.platform(libs.lib("koin-bom")))
                implementation(libs.lib("koin-core"))
                implementation(libs.lib("kotlinx-coroutines-core"))
            }
            sourceSets.getByName("commonTest").dependencies {
                implementation(libs.lib("kotlin-test"))
                implementation(libs.lib("kotlinx-coroutines-test"))
            }
        }
    }
}
