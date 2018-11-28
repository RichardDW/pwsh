Install-WindowsFeature Containers
Restart-Computer
Get-WindowsFeature containers
# Deploy Docker from PSGallery
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider

# Or download the latest development Docker from Docker directly;
Invoke-WebRequest "https://master.dockerproject.org/windows/amd64/docker-1.14.0-dev.zip" -OutFile "$env:TEMP\docker.zip" –UseBasicParsing
# extract the archive
Expand-Archive -Path "$env:TEMP\docker.zip" -DestinationPath $env:ProgramFiles
# create environment variable
$env:path += ";$env:ProgramFiles\Docker"
$existingMachinePath = [Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("Path", $existingMachinePath + ";$env:ProgramFiles\Docker", [EnvironmentVariableTarget]::Machine)
# register docker as a service
dockerd --register-service
# start the service
Start-Service Docker
# check
Get-Service -name "docker*"

# display Docker info
docker info
# deploy an IIS container
Docker run -d -p 8080:80 --name iis microsoft/iis
# docker command syntax
# docker run PUBLIC_PORT:PRIVATE_CONTAINER_PORT CONTAINER_NAME IMAGE