package eu.ballup.buildlogic

import org.gradle.api.JavaVersion
import org.gradle.api.Project
import org.gradle.api.artifacts.VersionCatalog
import org.gradle.api.artifacts.VersionCatalogsExtension
import org.gradle.kotlin.dsl.getByType
import org.gradle.kotlin.dsl.withType
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

val Project.libs: VersionCatalog
    get() = extensions.getByType<VersionCatalogsExtension>().named("libs")

fun VersionCatalog.intVersion(alias: String): Int = findVersion(alias).get().requiredVersion.toInt()

fun VersionCatalog.lib(alias: String) = findLibrary(alias).get()

/**
 * `:androidApp:feature:courts` -> `eu.ballup.feature.courts`
 * `:shared:core:model`         -> `eu.ballup.shared.core.model`
 */
fun Project.ballupNamespace(): String {
    val segments = path.removePrefix(":").split(":")
    val relevant = if (segments.first() == "androidApp") segments.drop(1) else segments
    return (listOf("eu", "ballup") + relevant)
        .joinToString(".") { it.replace("-", "").lowercase() }
}

/**
 * Same-named modules exist in `shared/feature` and `androidApp/feature`; distinct groups keep
 * their Gradle coordinates unique so dependency resolution never confuses them.
 */
fun Project.assignBallupGroup() {
    group = when (path.removePrefix(":").substringBefore(":")) {
        "androidApp" -> "eu.ballup.android"
        "shared" -> "eu.ballup.shared"
        else -> "eu.ballup"
    }
}

val Project.javaVersion: JavaVersion
    get() = JavaVersion.toVersion(libs.findVersion("jvmTarget").get().requiredVersion)

fun Project.configureKotlinJvmTarget() {
    val target = libs.findVersion("jvmTarget").get().requiredVersion
    tasks.withType<KotlinJvmCompile>().configureEach {
        compilerOptions.jvmTarget.set(JvmTarget.fromTarget(target))
    }
}
