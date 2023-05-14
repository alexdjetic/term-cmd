# enter audit mode
c:\Windows\System32\sysprep\sysprep.exe /audit

# install adk
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2196127" -OutFile "adksetup.exe"

# install deploy tool
cd Downloads
.\adksetup.exe /quiet /installpath e:\ADK /features OptionID.DeploymentTools 
