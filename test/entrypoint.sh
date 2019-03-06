#!/bin/sh
set -e

# See what kind of action this is
ACTION=$(cat /github/workflow/event.json | jq -r .action)
case $ACTION in
	opened)
		;;
	synchronize)
		;;
	*)
		echo "Not a PR open or push, exiting"
		exit 0
		;;
esac

cd "${GO_WORKING_DIR:-.}"

# Run tests
set +e
OUTPUT=$(go test -race -cover $(go list ./...) 2>&1)
SUCCESS=$?
set -e

# Exit if `go test` passes.
if [ $SUCCESS -eq 0 ]; then
  exit 0
fi

# Post results back as comment.
COMMENT="#### \`go test\`
$OUTPUT
"
PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)
curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null

exit $SUCCESS
