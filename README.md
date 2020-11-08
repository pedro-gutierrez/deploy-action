# Deploy Action

Opinionated action that builds, pushes a docker image to GitHub's container registry, then deploys it into Kubernetes.

## Usage

```yaml
- uses: pedro-gutierrez/deploy-action@v1
  name: Deploy
  with:
    docker_password: ${{ secrets.DOCKER_PASSWORD }}
    kubeconfig: ${{ secrets.KUBECONFIG }}
    secrets_name: mysecrets
    secrets: ${{ secrets.LIVE_SECRETS }}
```