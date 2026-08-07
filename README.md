# Homebrew Tap

Personal Homebrew tap maintained by [@arnostpleskot](https://github.com/arnostpleskot).

## Available packages

### Docker Sandboxes (`sbx`)

Linux Homebrew formula for [Docker Sandboxes](https://github.com/docker/sbx-releases).

Docker currently provides native Linux packages and release archives, but no official Homebrew formula for Linux. This formula installs the official Docker release artifacts and preserves Docker's expected `bin` / `libexec` runtime layout.

Install directly:

```bash
brew install arnostpleskot/tap/sbx
```

Or tap the repository first:

```bash
brew tap arnostpleskot/tap
brew install sbx
```

> [!NOTE]
> This formula is intended for Linux. macOS users should use Docker's official Homebrew distribution for Docker Sandboxes.

The formula installs:

* `sbx`
* the bundled Docker Sandboxes runtime components
* required `e2fsprogs` dependency
* Bash, Zsh, and Fish completions generated from the installed `sbx` version

Some optional host integrations, such as GPU passthrough setup and AppArmor configuration, require elevated privileges and are intentionally not performed automatically by Homebrew. Installation caveats provide the relevant commands where applicable.

## Brewfile

To use this tap with `brew bundle`:

```ruby
tap "arnostpleskot/tap"

brew "sbx"
```

## Updating

Once the tap is installed, packages update through the normal Homebrew workflow:

```bash
brew update
brew upgrade
```

## Homebrew documentation

For general Homebrew usage, see:

* `brew help`
* `man brew`
* [Homebrew documentation](https://docs.brew.sh)
