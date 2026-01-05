FROM node:25-bookworm

RUN npm install -g @anthropic-ai/claude-code@2.0.76

# install rust to a shared location accessible by any user
ENV RUSTUP_HOME=/opt/rust/rustup
ENV CARGO_HOME=/opt/rust/cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN chmod -R a+rwX /opt/rust
ENV PATH="/opt/rust/cargo/bin:${PATH}"
