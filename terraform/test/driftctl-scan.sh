#!/bin/bash

# Description: Run from the terraform root workspace, scans for drift
# You must have `iac.centeredgeops.IacAuditor` in your profile, or atleast a config that uses the correct role see below

# ```ini
# [profile iac.centeredgeops.IacAuditor]
# role_arn       = arn:aws:iam::833738481970:role/IacAuditor
# mfa_serial     = arn:aws:iam::472171537141:mfa/ayapejian
# source_profile = centeredge
# ```

# Exit immediately if a command exits with a non-zero status.
set -e

# Global variables
DCTL_CONFIG_DIR=${PWD}

# Main function
main() {
  driftctl scan --config-dir ${DCTL_CONFIG_DIR} --output console:// --output json://test/driftctl_results.json --output html://test/driftctl_results.html
}

# Call the main function
main "$@"
