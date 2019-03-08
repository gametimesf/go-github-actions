# go fmt

Runs `gofmt`. To learn more about `gofmt`, see the [official docs](https://golang.org/cmd/gofmt/).

```hcl
action "gofmt" {
  uses    = "gametimesf/github-actions/go/fmt@v0.3.0"
  needs   = "previous-action"
  secrets = ["GITHUB_TOKEN"]

  env {
    GO_WORKING_DIR = "./path/to/go/files"
  }
}
```
