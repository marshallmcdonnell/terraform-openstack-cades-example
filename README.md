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
terraform init # if first time
terraform plan # (optional) check the plan
terraform apply
```
4) Review and enter `yes` to accept the changes to infrastructure
5) Profit!!!

# Resources
Here is a list of some resources I found that have really helped in learning!

## Videos
 * Yevgeniy Brikman's 2017 HashiConf Talk "How to Build Reusable, Composable, Battle tested Terraform Modules" [video](https://www.youtube.com/watch?v=LVgP63BkhKQ&list=PLb4WHrYx4CZNqDHPIaXkFrezeq3GpSaT2&index=6&t=0s)
 * Nicki Watt's 2017 HashiDays Talk "Evoling Your Instrastructure with Terraform" [video](https://www.youtube.com/watch?v=wgzgVm7Sqlk&list=PLb4WHrYx4CZNqDHPIaXkFrezeq3GpSaT2&index=6) _great for pitfalls to avoid_
