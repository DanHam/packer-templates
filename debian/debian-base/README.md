# Building

Example build command:

```bash
PACKER_LOG=1 packer build -var-file vars/debian-common-variables.pkrvars.hcl -var-file vars/debian-12-variables.pkrvars.hcl . 2> packer.log
```
