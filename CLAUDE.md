# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo does

This is a GitHub profile README generator. `main.go` fetches the RSS feed from `https://cwchen-twn.github.io/rss.xml`, then renders `README.md.tmpl` into `README.md`. A GitHub Actions workflow runs this daily and commits the result.

## Commands

```sh
make build   # compile binary to /tmp/bin/cwc1222
make run     # build + run (regenerates README.md)
make tidy    # go mod tidy + go fmt
make updatedep  # go get -u ./... + go mod tidy
```

To run directly without building: `go run main.go`

## Architecture

- **`main.go`** — single entry point. Fetches RSS, limits to `maxPostsToShow` (5) items, executes `README.md.tmpl` with the item slice. If the feed fetch fails, it logs a warning and passes a `nil` slice so the blog section is silently omitted.
- **`README.md.tmpl`** — Go `text/template`. The blog posts section is wrapped in `{{ if . }}` so it is skipped when no feed items are available.
- **`README.md`** — generated output, committed by the CI bot. Do not edit by hand.
- **`.github/workflows/update-readme.yaml`** — runs on push, `workflow_dispatch`, and daily cron (`0 0 * * *`). Runs `go run main.go` and commits any diff.

## Key constants (`main.go`)

| Constant | Value |
|---|---|
| `blogRssFeed` | `https://cwchen-twn.github.io/rss.xml` |
| `maxPostsToShow` | `5` |
| `readmeTmplPath` | `README.md.tmpl` |
| `readmePath` | `README.md` |
