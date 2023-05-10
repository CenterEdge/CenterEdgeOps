#!/bin/bash

# Description: Run from the terraform root workspace, scans for drift
# SEE README.md in this dir

set -e

# Global variables
DCTL_CONFIG_DIR=${PWD}

# Main function
main() {
  echo "**********************"
  echo "Running as: (NOTE: If the ARN of the role doesn't contain 'IacAuditor' then you're probably using the wrong credentials)"
  aws sts get-caller-identity
  echo "**********************"
  # Automated snapshots cause coverage decline over time, ideally we'd use tags to exclude these resources, for now this works.
  driftctl scan --config-dir ${DCTL_CONFIG_DIR} --filter $'!(Type==\'aws_ebs_snapshot\' && starts_with(Id, \'snap-\'))' --output console:// --output json://test/driftctl_results.json --output html://test/driftctl_results.html
}

# Call the main function
main "$@"
