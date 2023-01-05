#!/usr/bin/env bash
set -euo pipefail

_tf_binary=/usr/local/bin/terraform
_root_envs_dir=/workspaces/CenterEdgeOps

declare -A _envs=(
    [admin]=$_root_envs_dir/terraform
)

# use first arg as tf command, otherwise 'init'
_tf_command="${1:-init}"

for _env in "${!_envs[@]}"
do
    echo "Running ${_tf_command} for \"${_env}\" in \"${_envs[$_env]}\""
    "${_tf_binary}" -chdir="${_envs[$_env]}" $_tf_command
done


