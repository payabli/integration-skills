# payabli-integration.md template

Write this file to the repo root. It is plain markdown — no YAML frontmatter. The consumer is always an LLM agent that reads the whole file into context, so the format is optimized for reading, not parsing. Section headers are a stable legibility convention, not a parsing contract.

Keep the first line exactly as shown — it is the schema version, used to migrate the format later.

## Template

```markdown
<!-- payabli-integration-plan: schema-v1 -->
# Payabli integration plan

## What we're integrating
<one or two sentences on the capability goal in the partner's words>

## App shape
<framework, language, and where payments live in the app>

## SDK
typescript-sdk

## Pay In
in scope

## Pay Out
not in scope

## Webhooks
in scope

## Tokenization
in scope

## Environment
sandbox

## Paypoint model
multi
```

## Controlled vocabulary

Use these exact values so downstream skills read them reliably. Human-context prose may follow the value on later lines.

| Section | Allowed values |
| --- | --- |
| `## SDK` | `typescript-sdk`, `python-sdk`, `csharp-sdk`, `java-sdk`, `go-sdk`, `php-sdk`, `ruby-sdk`, `rust-sdk`, `raw-http` |
| `## Pay In` | `in scope`, `not in scope` |
| `## Pay Out` | `in scope`, `not in scope` |
| `## Webhooks` | `in scope`, `not in scope` |
| `## Tokenization` | `in scope`, `not in scope` |
| `## Environment` | `sandbox`, `production` |
| `## Paypoint model` | `single`, `multi` |

`not in scope` is a valid value for any unused product section — include the section anyway.

## Guardrail

The artifact records **declared intent, not ground truth**. If the repo's actual code contradicts it (for example the plan says `raw-http` but the code already uses the SDK), prefer what the code shows and note the discrepancy.
