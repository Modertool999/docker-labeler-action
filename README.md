# Docker Labeler Action

A lightweight composite GitHub Action that wraps `docker` and `docker-buildx` to automatically inject **all** `GITHUB_*` environment variables as Docker image labels.

## Features

- **Zero configuration**: no inputs needed.
- **Full metadata**: captures workflow, run ID, job name, ref, SHA, etc.
- **Buildx support**: works for both `docker build` and `docker buildx build`.
- **Unmodified logs**: Docker’s output and error streams pass through unchanged.
- **Clear audit trail**: emits a single `[entrypoint] injecting labels: …` line before each build.

## Usage

1. Add the labeler step **first** in your job:

   ```yaml
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4

         - name: Wrap Docker
           uses: your-org/docker-labeler-action@v1

         - name: Build & Push
           uses: docker/build-push-action@v5
           with:
             context: .
             push: true
             tags: myorg/myapp:latest
