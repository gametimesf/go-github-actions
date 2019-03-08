# go test

If a Makefile exists in the repository, runs `make test`. Otherwise, runs `go test -race -cover`.

```hcl
action "go test" {
  uses    = "gametimesf/github-actions/go/fmt@v0.3.0"
  needs   = "previous-action"
  secrets = ["GITHUB_TOKEN", "ORG_GITHUB_TOKEN"]
}
```
