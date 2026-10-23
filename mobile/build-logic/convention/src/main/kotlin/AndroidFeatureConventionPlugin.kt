import eu.ballup.buildlogic.lib
import eu.ballup.buildlogic.libs
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.dependencies
import org.gradle.kotlin.dsl.project

/**
 * Android UI feature (Compose screens + ViewModels).
 * `:androidApp:feature:<name>` automatically depends on its data/domain twin `:shared:feature:<name>`.
 */
class AndroidFeatureConventionPlugin : Plugin<Project> {
    override fun apply(target: Project) = with(target) {
        pluginManager.apply("ballup.android.library")

        dependencies {
            add("implementation", project(":androidApp:core:designsystem"))
            add("implementation", project(":androidApp:core:ui"))
            add("implementation", project(":shared:feature:${project.name}"))

            add("implementation", platform(libs.lib("koin-bom")))
            add("implementation", libs.lib("koin-compose-viewmodel"))
            add("implementation", libs.lib("androidx-lifecycle-runtime-compose"))
            add("implementation", libs.lib("androidx-lifecycle-viewmodel-compose"))
            add("implementation", libs.lib("androidx-navigation3-runtime"))

            add("testImplementation", project(":shared:core:testing"))
            add("androidTestImplementation", libs.lib("androidx-compose-ui-test-junit4"))
            add("debugImplementation", libs.lib("androidx-compose-ui-test-manifest"))
        }
    }
}
