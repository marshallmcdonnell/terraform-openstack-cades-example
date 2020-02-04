# Get RC file for credentials for OpenStack

From web portal
1) Login to [CADES OpenStack]()
2) Go to `Compute` -> `Access & Security` -> `API Access`
3) Hit the `Dowload OpenStack RC File v3` Button
4) Save file for sourcing later

[Direct link](https://cloud.cades.ornl.gov/dashboard/project/access_and_security/api_access/openrc/) to step 3

# Add an instance using Terraform
1) Source the RC file
2) Enter password
3) Run:
```
terraform apply
```
4) Review and enter `yes` to accept the changes to infrastructure
5) Profit!!!
