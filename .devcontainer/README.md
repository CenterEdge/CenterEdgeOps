# Devcontainer

_NOTE: This is almost a verbatim copy of `IAC.Monitors` version of the `.devcontainer` dir, should still be moved and built out globally, just referencing here as there are multiple versions of the devcontainer out in other projects at this point :/_

_NOTE: For the devcontainer to startup and mount various host config files into the container for aws auth, git config, etc... You **must have the HOME environment variable setup in your HOST environment**_

Devcontainer uses [awsume](https://awsu.me/) to assume roles. The container maps your `~/.aws` directory into the container's `vscode` user's dir allowing role assumption same as docker host machine.

```shell
# Assume centeredge role (only needed once per container launch or if creds expire)
awsume centeredge

# Run terraform
cd envs/centeredgecloudprod
terraform init
terraform (plan|apply)
```
