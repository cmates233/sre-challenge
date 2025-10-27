## Part 2 - The application

### The build tool
I've used Cloud Build since I'm more familiar with it and has a good ease of use with Kubernetes. Nonetheless, this could also be done with GitHub actions should this be required.

### The workflow

The idea was to preserve the go app as if it was inmutable: All changes required should go outside.

In order to successfully build the app, we'll need to init the go.mod dependencies. This would be done with: `go mod init app`. After this, we could prepare:

1. The Dockerfile
2. The cloudbuild.yaml