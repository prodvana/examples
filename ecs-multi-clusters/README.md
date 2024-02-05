# ECS Multi Clusters

These configs show an Application being deployed across multiple ECS Runtimes, each with its own network settings.

There are three ways to handle Runtime differences.

1. (recommended) Use a different ECS service definition file per Release Channel, but ensure the file names follow a predictable pattern. This is shown via the Service `nginx-diff-files-predictable`.
2. Use a different ECS service definition file per Release Channel. This is shown via the Service `nginx-diff-files`.
3. Use templating. This is shown via the Service `nginx-templating`.
