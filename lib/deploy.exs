workspace = "/github/workspace"
home = "/github/home"
docker_registry = "docker.pkg.github.com"

repo = Env.ensure("GITHUB_REPOSITORY")
secrets_name = Env.ensure("INPUT_SECRETS_NAME", "secrets")

short_sha = Shell.run("cd #{workspace}; git rev-parse --short HEAD")
now = Shell.run("date +%F-%T")
version = "#{now}-#{short_sha}"

secrets =
  "INPUT_SECRETS"
  |> Env.ensure()
  |> Base.decode64!()
  |> Jason.decode!()

secrets =
  secrets
  |> Map.put("DEPLOYMENT_VERSION", version)
  |> Enum.map(fn {k, v} ->
    "--from-literal='#{k}=#{v}'"
  end)
  |> Enum.join(" ")
  |> IO.inspect()

[repo_owner, _repo_name] = String.split(repo, "/")

Shell.run("Setup Docker...", [
  "echo $INPUT_DOCKER_PASSWORD | docker login #{docker_registry} -u #{repo_owner} --password-stdin"
])

Shell.run("Setup Kubernetes...", [
  "mkdir -p #{home}/.kube",
  "echo $INPUT_KUBECONFIG | base64 -d > #{home}/.kube/config"
])

Shell.run("Create Docker secret for Kubernetes...", [
  "kubectl delete secret docker --ignore-not-found",
  "kubectl create secret generic docker --from-file=.dockerconfigjson=#{home}/.docker/config.json --type=kubernetes.io/dockerconfigjson"
])

Shell.run("Update secrets...", [
  "kubectl delete secret #{secrets_name} --ignore-not-found",
  "kubectl create secret generic #{secrets_name} #{secrets}"
])

Shell.run("Deploy...", [
  "kubectl apply -f #{workspace}/k8s.yml"
])

IO.put("Success!")
