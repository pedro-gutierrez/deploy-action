workspace = "/github/workspace"
home = "/github/home"
docker_registry = "docker.pkg.github.com"

repo = Env.ensure("GITHUB_REPOSITORY")
[repo_owner, repo_name] = String.split(repo, "/")

docker_tag = Env.ensure("INPUT_DOCKER_TAG", "latest")
image_tag = "#{docker_registry}/#{repo_owner}/#{repo_name}/#{repo_name}:#{docker_tag}"

secrets_name = Env.ensure("INPUT_SECRETS_NAME", "secrets")

short_sha = Shell.run("cd #{workspace}; git rev-parse --short HEAD")
now = Shell.run("date +%F-%T")
version = "#{now}-#{short_sha}"

secrets =
  "INPUT_SECRETS"
  |> Env.ensure()
  |> Base.decode64!()
  |> Jason.decode!()
  |> Enum.map(fn {k, v} ->
    "--from-literal='#{k}=#{v}'"
  end)
  |> Enum.join(" ")

Shell.run("Build and push Docker image...", [
  "echo $INPUT_DOCKER_PASSWORD | docker login #{docker_registry} -u #{repo_owner} --password-stdin",
  "cd #{workspace}; docker build -t #{image_tag} .",
  "docker push #{image_tag}"
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
  "sed -i \"s/{{VERSION}}/#{version}/g\" #{workspace}/k8s.yml",
  "kubectl apply -f #{workspace}/k8s.yml"
])

pods_to_kill = Env.ensure("KILL_PODS", "none")

if pods_to_kill != "none" do
  Shell.run("Deleting pods with label #{pods_to_kill}", [
    "kubectl delete pods -l #{pods_to_kill}"
  ])
end

IO.puts("Success!")
