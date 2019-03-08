FROM golang:1.12

LABEL "com.github.actions.name"="go test"
LABEL "com.github.actions.description"="Run go test"
LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/gametimesf/github-actions"
LABEL "homepage"="https://github.com/gametimesf/github-actions"
LABEL "maintainer"="Andy Janata <andy.janata@gametime.co>"

RUN apt-get update
RUN apt-get install -y jq

# RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
