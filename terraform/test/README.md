Testing terraform code coverage.

Each AWS account has an "IacAuditor" role which must be assumed to run the drift detection.  You'll want to follow these steps to run locally ( within the devcontainer )

# Setup the IacAuditor profile in your AWS Config file (one time setup)

The AWS config dir (`~/.aws`) is mounted into the devcontainer, giving you secure access to all your aws profiles, you'll need to add an entry for the IacAuditor role for this account, these values may need to be changed to match what you have set already.

Example `~/.aws/config` profile

```ini
[profile centeredge]
output=json
region=us-east-1
mfa_serial=arn:aws:iam::472171537141:mfa/ayapejian

[profile iac.centeredgeops.IacAuditor]
role_arn       = arn:aws:iam::833738481970:role/IacAuditor
mfa_serial     = arn:aws:iam::472171537141:mfa/ayapejian
source_profile = centeredge
```

# Running the drift detection

The profile names are arbitrary however these are the values used above

1. Authenticate with MFA ( Only on first container start or after some hours )
```shell
awsume centeredge
```

2. Now you are authenticated with MFA, assume the IacAuditor role for this account

```shell
awsume iac.centeredgeops.IacAuditor
```

3. Run the `driftctl-scan.sh` script from the terraform root (NOT THE TEST DIR)

```shell
$ pwd
/workspaces/CenterEdgeOps/terraform
$ test/driftctl-scan.sh
```

## Results

Results are sent to the console as well as saved to the `.../terraform/test` directory as `driftctl_results.<format>` files to be consumed downstream as needed.

# Troubleshooting

Most issues are usually permissions / assumed role based.  When you run the shell script it will output `aws sts get-caller-identity` and it should list you as something like `"Arn": "arn:aws:sts::833738481970:assumed-role/IacAuditor/iac.centeredgeops.IacAuditor"` based on the account role you're assuming.  If you see your user name in there you're probably doing it wrong.

