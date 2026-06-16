# SDK detection and language mapping

Payabli ships official server SDKs for 8 languages. The API can also be called directly over HTTP (recorded as `raw-http`); the SDK is an option to **suggest when it fits**, not a default.

| Language | Detect via | SDK guide |
| --- | --- | --- |
| TypeScript / Node | `package.json` | https://docs.payabli.com/developers/platform-sdk-typescript-guide.md |
| Python | `pyproject.toml`, `requirements.txt` | https://docs.payabli.com/developers/platform-sdk-python-guide.md |
| C# | `*.csproj` | https://docs.payabli.com/developers/platform-sdk-csharp-guide.md |
| Java | `pom.xml`, `build.gradle` | https://docs.payabli.com/developers/platform-sdk-java-guide.md |
| Go | `go.mod` | https://docs.payabli.com/developers/platform-sdk-go-guide.md |
| PHP | `composer.json` | https://docs.payabli.com/developers/platform-sdk-php-guide.md |
| Ruby | `Gemfile` | https://docs.payabli.com/developers/platform-sdk-ruby-guide.md |
| Rust | `Cargo.toml` | https://docs.payabli.com/developers/platform-sdk-rust-guide.md |

Overview of all SDKs: https://docs.payabli.com/developers/platform-sdk-server-overview.md

Package names don't track the `*-sdk` value (npm `@payabli/sdk-node`, PyPI `payabli`) — take the exact install command from the SDK guide, don't guess it.

## Detection steps

1. Look for the manifest files above at the repo root.
2. If one matches a shipped SDK, you may suggest it as an option — don't push it. Otherwise build for `raw-http`.
3. Record the choice in `payabli-integration.md` under `## SDK` as one of: `typescript-sdk`, `python-sdk`, `csharp-sdk`, `java-sdk`, `go-sdk`, `php-sdk`, `ruby-sdk`, `rust-sdk`, or `raw-http`.

## Interop languages

If the project's language has no Payabli SDK but interops first-class with one that does, the parent language's SDK is reachable, often ergonomically. Examples: Kotlin and Scala → Java; F# → C#; ReScript and PureScript → TypeScript; Julia → Python.

Weigh the cost with the partner before recommending interop:

- Is interop infrastructure already in place (for example, a Kotlin codebase already calling Java libraries)?
- Is an interop layer worth introducing, or is raw HTTP cleaner here?

## No path

If no SDK exists and there is no usable interop path (for example Elixir, Swift, Erlang), use raw HTTP without comment.
