---
name: payabli-mcp-setup
description: >-
  Use when the developer wants to install or configure the official Payabli Docs
  MCP server in their coding agent (Claude Code, Cursor, Codex, Gemini, Copilot
  CLI). Triggers on "install the Payabli Docs MCP," "set up Payabli Docs MCP," or
  "add the Docs MCP server." Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli Docs MCP setup

Install the official Payabli Docs MCP server in the developer's coding agent. The MCP answers questions against Payabli's docs and SDK references — it complements these skills (skills sequence the work; the MCP answers Q&A).

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## Install

The MCP server endpoint is `https://mcp.inkeep.com/payabli/mcp`. Configure it for the developer's coding agent — the per-agent setup (Cursor `.cursor/mcp.json`, Claude Desktop, and other MCP clients) is on the Docs MCP page. Detect which agent the developer uses and apply the matching config.

https://docs.payabli.com/developers/platform-developer-mcp.md

## After install

The MCP exposes tools to search the docs and ask questions about Payabli. Recommend it for ongoing Q&A during the build; the skills remain the source of procedural sequencing.

Pairs with `payabli-getting-started`, which recommends installing the Docs MCP as part of onboarding.
