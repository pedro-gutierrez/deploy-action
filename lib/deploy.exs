docker_registry = "docker.pkg.github.com"
[repo_owner, _repo_name] = "GITHUB_REPOSITORY" |> System.get_env() |> String.split("/")
home = "/github/home"
workspace = "/github/workspace"
docker_config_file = "#{home}/.docker/config.json"

Shell.run("Setup Docker...", [
  "echo $INPUT_DOCKER_PASSWORD | docker login #{docker_registry} -u #{repo_owner} --password-stdin"
])

Shell.run("Setup Kubernetes...", [
  "mkdir -p ~/.kube",
  "echo $INPUT_KUBECONFIG | base64 -d > ~/.kube/config"
])

Shell.run("Create Docker secret for Kubernetes...", [
  "kubectl delete secret docker --ignore-not-found",
  "kubectl create secret generic docker --from-file=.dockerconfigjson=/github/home/.docker/config.json --type=kubernetes.io/dockerconfigjson"
])

short_sha = Shell.run("cd #{workspace}; git rev-parse --short HEAD")
now = Shell.run("date +%F-%T")
version = "#{now}-#{short_sha}"

secrets_name = System.get_env("INPUT_SECRETS_NAME", "secrets")
secrets = System.get_env("INPUT_SECRETS") |> Base.decode64!() |> Jason.decode!()

Shell.run("Update secrets", [
  "kubectl delete secret #{secrets_name} --ignore-not-found"
])

Shell.run("Set version and deploy", [
  "sed -i \"s/{{VERSION}}/#{version}/g\" #{workspace}/k8s.yml",
  "kubectl apply -f #{workspace}/k8s.yml"
])
