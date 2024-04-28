# subspace_cli_update<br>
Script for update Subspace Network Node for Linux or Mac CLI.


# Install CURL and JQ:<br>

`sudo apt update && sudo apt install curl jq`<br><br>

# Donwload script:<br>
`wget -qO- https://raw.githubusercontent.com/kir3d/subspace_cli_update/ss_update.sh && chmodd +x ss_update.sh`<br><br>

# Run script
`./ss_update.sh`


I not recommend put in cron because need checking logs for correct restart services.
