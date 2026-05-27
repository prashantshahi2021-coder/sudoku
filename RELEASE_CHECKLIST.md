# Sudoku Release Checklist

## Deobfuscation File

The current Android release build has code shrinking disabled:

- `isMinifyEnabled = false`
- `isShrinkResources = false`

Because minification/obfuscation is off, the release AAB does not need a deobfuscation file and `android/app/build/outputs/mapping/release/mapping.txt` is not generated.

If minification is enabled in a future release, keep the generated mapping file at:

`android/app/build/outputs/mapping/release/mapping.txt`

Upload that `mapping.txt` file to Play Console for the matching version code so crash reports can be deobfuscated.
