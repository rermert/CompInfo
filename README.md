<snippet>
  <content><![CDATA[
# ${1:CompInfo}
A script that takes Powershell queries to gather information on your local or remote Windows machines.
## Installation
Simply download the script.
## Usage
TODO: Write usage instructions
## Notes/Debugging
1. If you haven't ran a Powershell script before you may run into the following error:
   "execution of scripts is disabled on this system" or something similar.
   To fix this, open Powershell and run the following command: 
   `Set-ExecutionPolicy RemoteSigned`
2. If you are trying to query a remote machine, the following must be true:
   1) You are querying a windows machine
   2) The machine is currently on and a user is logged in
   3) The machine is connected to the RPC server
3. For any further questions/concerns please open a new issue
## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
]]></content>
  <tabTrigger>readme</tabTrigger>
</snippet>
