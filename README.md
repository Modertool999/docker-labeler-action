# Docker Labeler Action

A GitHub Action that wraps `docker` and `docker-buildx` to automatically inject **all** `GITHUB_*` environment variables as Docker image labels.

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
