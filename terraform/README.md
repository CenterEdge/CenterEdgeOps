# Terraform

- [Terraform](#terraform)
  - [Initial Setup](#initial-setup)
  - [Importing existing resources](#importing-existing-resources)
    - [Import Example](#import-example)
  - [Terraform Tips & Suggestions](#terraform-tips--suggestions)

## Initial Setup

1. Download terraform
   1. NOTE: Recommend staying with [v0.11.14](https://releases.hashicorp.com/terraform/0.11.14/) until we migration all repos to v0.12.x as terraform is dependent on local install and this avoids having to manage multiple binaries based on which repo you're working in.
2. Clone repo, open shell, cd to `<repo_root>/terraform`
3. Authenticate with your [root IAM user account](https://centeredge.atlassian.net/wiki/spaces/DO/pages/5116109/AWS+Authentication+and+Credentials)
  ```powershell
    UseAWSToken -Profile centeredge -SetEnvironment
  ```
3. Initialize repo
   ```powershell
   terraform init
   ```
4. Review [terraform docs](https://learn.hashicorp.com/terraform/getting-started/build) for general terraform functionality and the [aws provider](https://www.terraform.io/docs/providers/aws/index.html) docs for resource specific info

## Importing existing resources

Importing resources into terraform only adds the existing resource to your terraform state file, meaning if you run import and then `terraform apply` **terraform will destroy the imported resource** since now something exists within your state file which has no cooresponding terraform configuration to match it.  To avoid this ensure that you add a configuration block to match your imported resource, in addition you'll have to consult the [provider docs](https://www.terraform.io/docs/providers/aws/index.html) to see what options exist that you'll have to populate with the current aws resource configuration (ami for ec2 image, subnet for vpc, etc.. ).

Unfortunately the above procedure is only mildly helpful since most of the process is a manual trial and error.  One utility that may be of use to you is [terraforming](https://github.com/dtan4/terraforming) which looks up aws resources and dumps out terraform configuration blocks to stdout.  This is a non-destructive operation by default, meaning you can run `terraforming` (without switches) and no state will be altered.  The output of `terraforming` can be used as a basis for your terraform configuration matching imported resources (or close to matching anyways)

### Import Example

1. First identify the aws resource, for this example we'll use the Ops [`BackupUploader`](https://console.aws.amazon.com/iam/home?region=us-east-1#/users/BackupUploader) IAM user

2. Either manually add a configuration block for the [associated aws provider resource](https://www.terraform.io/docs/providers/aws/r/iam_user.html) or use terraforming to dump a config block if the tool supports the resource.  In this case running `terraforming iamu` which dumps all iam users

3. Lookup the way import works for the particular resource, in the [iam_user](https://www.terraform.io/docs/providers/aws/r/iam_user.html) case the import is done by name. `terraform import aws_iam_user.backup-uploader BackupUploader`

4. The goal at this point is to ensure terraform sees no changes are needed, meaning the iam user was imported into the state, the terraform configuration block for the iam user exists and all attributes of `aws_iam_user.backup-uploader` match the actual attributes of the `BackupUploader` iam user as seen within AWS currently.
   * If no changes are detected you are done, you can run `terraform apply` to confirm but that should be a noop as well
   * If changes are detected you'll have to identify what the differences, update the config, and run `terraform plan` again until a clean, no-changes detected, run is achieved.

_Note: Using `terraforming` output gives you a config block with all hard coded values, there is no chaining of associated resources. For example when importing an ec2 instance the subnet id would be among all the hardcoded values, at some point in the future you'll have to import that subnet for one reason or another, at this point you should find all references to the subnet and replace it with whatever subnet attribute is needed from the resource (replace hardcoded id with `${aws_subnet.my-subnet.id}`) across all files in the project.  To make this easier on yourself you have two options_

1. Pre-substitue hardcoded values with `local` variables to make search/repalce easier

2. If available for a specific resource you could use the terraform `data` resource for the hardcoded value, in the previous example the [data.aws_subnet](https://www.terraform.io/docs/providers/aws/d/subnet.html) resource could be used to reference the subnet without having to first import, then when imported the data resource can be searched for and replaced with the actual imported subnet resouce


## Terraform Tips & Suggestions

_NOTE: Take with a grain for salt as most of these are heavily dependent on preference_

1. Resources are all `_` having vars as all `-` case makes search/replace refactors a little easier, without having to regex it, when resource _type_ is repeated in resource _name_ (`aws_iam_user.iam_user_developer` for instance)
2. Add a tag of `Terraform: true` to all resources that support tags in aws, this will make it easier to know which resources have been imported into terraform and which still need migration when using the aws cli or console.
3. Help enforce a default set of tags by merging tags with a common set.  See [variables.tf](variables.tf) `local.default_tags` variable and how it's used by `aws_instance.SupportOps` in [ec2.tf](ec2.tf)
4. Use [variables](https://learn.hashicorp.com/terraform/getting-started/variables.html) for things that will be reused within the project globally, use [local](https://www.terraform.io/docs/configuration/locals.html) for variables within a file
5. Terraform [modules](https://www.terraform.io/docs/configuration/modules.html) can be used as either a way to reuse common tightly related resources but it's also useful for just structuring the project even if the module will not be reused
6. As your project grows, or while trying to grep what's going on in some other terraform repository, [blast-radius](https://github.com/28mm/blast-radius) is a really nice tool to have in your back pocket.
7. The [terraform module registry](https://registry.terraform.io/) is great if you can find a module that matches what you need, it's also extremely helpful to get an idea on what you might need to code manually in terraform like [aws_vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc)

