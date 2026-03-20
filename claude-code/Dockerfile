FROM wb14123/coding-agent-base:latest

ARG CLAUDE_VERSION=2.1.80

RUN curl -fsSL https://claude.ai/install.sh | bash -s ${CLAUDE_VERSION} && \
    mv /root/.local/bin/claude /usr/local/bin/claude
