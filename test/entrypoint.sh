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

# Set up GOPATH
if [ -z "${IMPORT}" ]; then
  IMPORT="${GITHUB_REPOSITORY}"
fi
WORKDIR="${GOPATH}/src/github.com/${IMPORT}"

mkdir -p "$(dirname "${WORKDIR}")"
ln -s "${PWD}" "${WORKDIR}"
cd "${WORKDIR}"

# Run tests
set +e
if [ -r Makefile ]; then
	OUTPUT=$(make test 2>&1)
	SUCCESS=$?
else
	OUTPUT=$(go test -race -cover $(go list ./...) 2>&1)
	SUCCESS=$?
fi
echo "$OUTPUT"
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
