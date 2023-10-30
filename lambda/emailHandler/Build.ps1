Set-Location $PSScriptRoot

Write-Host "Deleting `".\dist`"..." -ForegroundColor DarkCyan
Remove-Item -Path .\dist\ -Recurse -Force

Write-Host "Removing all packages and installing only production packages..." -ForegroundColor DarkCyan
Remove-Item -Path .\node_modules\ -Recurse -Force
npm install --omit=dev --no-audit --no-fund

Write-Host "Copying the production modules to the dist folder..." -ForegroundColor DarkCyan
Copy-Item -Path .\node_modules\ -Destination .\dist\node_modules\ -Recurse -Force

Write-Host "Installing all packages and compiling the code..." -ForegroundColor DarkCyan
npm install --no-audit --no-fund
npx tsc

Write-Host "Creating the final archive..." -ForegroundColor DarkCyan
Compress-Archive -Path .\dist\* -DestinationPath .\dist\emailHandler.zip -Force

Write-Host "Cleaning up..." -ForegroundColor DarkCyan
Remove-Item -Path .\dist\node_modules -Recurse -Force
Remove-Item -Path .\dist\index.js -Force