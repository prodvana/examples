# ECS with Analysis

These configs show an Application deploying to ECS, with an analysis step that verifies the state of canary Release Channel before going to the production Release Channels. The analysis runs as a Convergence Extension, which will run until it succeeds once after approval is submitted, executing on the Kubernetes Runtime while Services run on the ECS Runtime.
