## Building the project

To build the project, run the .\Build.ps1 script with PowerShell.

```powershell
.\Build.ps1
```

This will produce an emailHandler.zip file in the .\dist folder. To then deploy the function to production, the zip package should be uploaded to s3://centeredge-techfiles/lambda/emailHandler.zip

## Testing

To test the function code, first authenticate to the Ops account with AWSAuth:

```powershell
Use-AWSToken -ProfileName default -RoleNameOrArn <role:arn:goes:here> -SetEnvironment
```

Your IAM role will need permission to read the centeredge-ops-emails bucket and write to the `adv-db-msgs` Dynamo DB table.

When ready, use the harness in .\test\test.js.

```powershell
node .\test\test.js
```

You can copy records logged to CloudWatch (the first log posted for every invocation) and replace the data in .\test\test_event.json.