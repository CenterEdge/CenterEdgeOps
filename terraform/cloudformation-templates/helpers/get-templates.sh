#!/bin/bash
# Fetches stacks defined in array and dumps to json files for use in tf resources.
# NOTE: Changes to templates moving forward should be made in terraform and pushed to cf, this script is here in
# case there is a need while ops is onboarding with tf

# TODO: get these names automatically via `aws cloudformation list-stacks`
declare STACKS=(
    SnapshotDaily30
    Expire60
    Keep30
    SnapshotDailyMin
    Keep7
    Expire30
    Highlander
    SnapshotDaily
    DevOpsAutomator
)

for STACK_NAME in "${STACKS[@]}"
do
    echo "Fetching $STACK_NAME"
    aws cloudformation get-template --stack-name "$STACK_NAME" | jq .TemplateBody > "$STACK_NAME.json"
done
