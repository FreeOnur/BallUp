import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.configure
import org.jetbrains.kotlin.gradle.dsl.KotlinMultiplatformExtension

/** Shared feature module: `data/` (repositories, local + remote sources) and `domain/` (use cases). */
class KmpFeatureConventionPlugin : Plugin<Project> {
    override fun apply(target: Project) = with(target) {
        pluginManager.apply("ballup.kmp.library")

        extensions.configure<KotlinMultiplatformExtension> {
            sourceSets.getByName("commonMain").dependencies {
                implementation(project(":shared:core:model"))
                implementation(project(":shared:core:common"))
                implementation(project(":shared:core:domain"))
                implementation(project(":shared:core:data"))
            }
            sourceSets.getByName("commonTest").dependencies {
                implementation(project(":shared:core:testing"))
            }
        }
    }
}
