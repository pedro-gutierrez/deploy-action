#! /usr/bin/env elixir
defmodule Shell do
    def run(title, cmds) when is_list(cmds) do
        IO.puts title
        Enum.each(cmds, &run(&1))
    end

    def run(cmd) do
        {output, status} = System.cmd("sh", ["-c", cmd])
        if status != 0 do
            IO.inspect(cmd: cmd, rc: status, output: output)
            System.halt(status)
        end
        String.trim(output)
    end
end

docker_registry = "docker.pkg.github.com"
[repo_owner, _repo_name] = "GITHUB_REPOSITORY" |> System.get_env() |> String.split("/")
#docker_config_file = "/github/home/.docker/config.json"

#Shell.run("Setup Docker...", [
#    "echo $INPUT_DOCKER_PASSWORD | docker login #{docker_registry} -u #{repo_owner} --password-stdin"
#    ]
#)
#
#Shell.run("Setup Kubernetes...", [
#    "mkdir -p ~/.kube",
#    "echo $INPUT_KUBECONFIG | base64 -d > ~/.kube/config"
#])
#
#Shell.run("Create Docker secret for Kubernetes", [
#    "kubectl delete secret docker --ignore-not-found",
#    "kubectl create secret generic docker --from-file=.dockerconfigjson=/github/home/.docker/config.json --type=kubernetes.io/dockerconfigjson"
#])

#short_sha = Shell.run("git rev-parse --short HEAD")
now = Shell.run("date +%F-%T")
now = Shell.run("pwd")
IO.inspect(now: now)


#set -e
#
#
#REGISTRY=docker.pkg.github.com
#REPO_OWNER=`echo $GITHUB_REPOSITORY | cut -d'/' -f1`
#REPO_NAME=`echo $GITHUB_REPOSITORY | cut -d'/' -f2`
#
#echo "Authenticating with $REGISTRY as $REPO_OWNER..."
#echo $INPUT_PASSWORD | docker login $REGISTRY -u $REPO_OWNER --password-stdin
#
#echo "Configuring Kubernetes CLI..."
#mkdir -p ~/.kube
#echo $INPUT_KUBECONFIG | base64 -d > ~/.kube/config
#
#echo "Creating Docker secret for Kubernetes..."
#kubectl delete secret docker --ignore-not-found
#kubectl create secret generic docker \
#    --from-file=.dockerconfigjson=/github/home/.docker/config.json \
#    --type=kubernetes.io/dockerconfigjson
#
#echo "Configuring deployment version..."
#export GIT_SHA_SHORT=$(git rev-parse --short HEAD)
#export CURRENT_DATE=$(date +%F-%T)
#export VERSION="$CURRENT_DATE-$GIT_SHA_SHORT"
#sed -i "s/{{VERSION}}/$VERSION/g" k8s.yml
#echo "Deploying $VERSION"
#
#echo "Deploying..."
#kubectl apply -f k8s.yml