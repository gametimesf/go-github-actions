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

post() {
	OUTPUT="$1"
	# Post results back as comment.
	COMMENT="#### \`go test\`
$OUTPUT
"
	PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
	COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)
	curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null
}

# Set up GOPATH
if [ -z "${IMPORT}" ]; then
  IMPORT="${GITHUB_REPOSITORY}"
fi
WORKDIR="${GOPATH}/src/github.com/${IMPORT}"

mkdir -p "$(dirname "${WORKDIR}")"
ln -s "${PWD}" "${WORKDIR}"
cd "${WORKDIR}"

git config --global url."https://${GITHUB_TOKEN}@github.com/gametimesf".insteadOf "https://github.com/gametimesf"

# Ensure dependencies exist
set +e
if [ -r Gopkg.lock ]; then
	OUTPUT=$(dep ensure 2>&1)
	SUCCESS=$?
fi
if [ -r go.mod ]; then
	OUTPUT=$(go mod download 2>&1)
	SUCCESS=$?
fi
set -e

echo "$OUTPUT"
if [ $SUCCESS -ne 0 ]; then
	post "$OUTPUT"
	exit $SUCCESS
fi

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

post "$OUTPUT"

exit 0
