# go fmt

Runs `gofmt`. To learn more about `gofmt`, see the [official docs](https://golang.org/cmd/gofmt/).

*NOTE*: This action must be before the `go test` action, or any other action that populates the vendor directory. All of my attempts to exclude that directory from gofmt have failed... :(

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
