package eu.ballup.shared

/**
 * Entry point of the iOS framework `Shared`.
 *
 * Also guarantees the framework has compiled content while the shared modules are still empty;
 * without any Kotlin source Gradle skips linking and Xcode finds no `Shared.framework`.
 */
object BallUpShared {
    const val VERSION: String = "0.1.0"
}
