# Docker Labeler Action

A GitHub Action that transparently wraps `docker` and `docker-buildx` to inject all `GITHUB_*` environment variables (plus optional extra labels) into every image build as Docker labels.

## Features

* Automatically moves the runner’s real `docker` and `docker-buildx` binaries aside and installs the wrapper.
* Collects **all** `GITHUB_*` environment variables and appends them as `--label KEY=VALUE` to every `docker` invocation.
* Supports an optional `extra-labels` input for comma-separated additional labels.
* Logs the injected labels in the build logs for visibility.

## Inputs

| Input          | Required | Description                                                          |
| -------------- | -------- | -------------------------------------------------------------------- |
| `extra-labels` | false    | Comma-separated `KEY=VALUE` pairs to add as additional Docker labels |

## Usage

Add the wrapping step **before** any `docker` or `docker/build-push-action` steps in your workflow:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Wrap Docker CLI
        uses: your-org/docker-labeler-action@v1
        with:
          extra-labels: "ENV=prod,RELEASE=${{ github.sha }}"

      - name: Build & Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: your-org/myapp:latest
```

Any subsequent `docker` or `docker buildx` command in that job will have labels automatically injected.

## Testing

### 1. Local dry-run with [`act`](https://github.com/nektos/act)

If you have [act](https://github.com/nektos/act) installed:

```bash
# Run your workflow locally using the ubuntu-latest image
act -j build
```

Watch the logs for the `[entrypoint] injecting labels:` line and verify the labels in the built image.

### 2. End-to-end on GitHub

1. Push a test branch to your repository that includes the `ci.yml` workflow from Usage.
2. Go to **Actions → Workflows** and manually trigger the workflow (if using `workflow_dispatch`).
3. In the job logs, confirm you see the injection log and then inspect the image labels:

   ```bash
   docker inspect your-org/myapp:latest | jq '.[0].Config.Labels'
   ```

### 3. Local script-only test

If you just want to verify the wrapper logic without a full GitHub runner:

1. Copy `entrypoint.sh` and a `Dockerfile` into an empty directory.
2. Fetch your Docker binary:

   ```bash
   cp "$(which docker)" ./docker-original
   chmod +x ./docker-original
   ```
3. Export some fake GitHub envs:

   ```bash
   export GITHUB_RUN_ID=123 GITHUB_JOB=test
   ```
4. Run:

   ```bash
   ./entrypoint.sh build . -t demo:test
   ```
5. Verify labels:

   ```bash
   docker inspect demo:test | jq '.[0].Config.Labels'
   ```

---

That’s it! Feel free to adjust the examples to match your org’s repo names and tags. Let me know if you’d like more guidance or further automation.
