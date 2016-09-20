## HashiStack on AWS

This repo is inspired by [kelseyhightower/hashiconf-eu-2016](https://github.com/kelseyhightower/hashiconf-eu-2016) to create hashistack(Consul/Nomad/Vault) cluster over AWS , easy bootstrap compare with  kelseyhightower's original one . 

### Example setup
```
1 VPC
3 server subnet over 3 aws zone
3 client subnet over 3 aws zone
1 or 3 servers , 1 server on each zone if it is 3 servers
1 autoscaling group to  nomad client/agents , user can defined ASG size for nomad
```
Above subnets are all public and only accessed from your desktop public ip , you need setup your ip in dev.tfvars.example

### Bootstrap
clone this repo
```
cd terraform
```

edit [dev.tfvars.example](terraform/dev.tfvars.example) , update my_ip to your public ip/sshkey and other variable if you want.

```
terraform plan -var-file=dev.tfvars.example
terraform apply -var-file=dev.tfvars.example
```

### To Use

Run two system jobs
```
export NOMAD_ADDR=http://<public ip of any of server>:4646
```
make sure nodes are all ready

`nomad node-status`

As there is an issue with memory.limit_in_bytes issue on debian8 , I add reboot in userdata , it will make node up become slow as it needs reboot for the first time . If you choose ubuntu or other host os , you can just remove fix from [client.tpl](terraform/client.tpl) 
```
cd jobs
nomad run consul.nomad
nomad run fabio.nomad
```
Access consul UI
`http://<public ip of any of server>:8500/ui`

### Licnese
MIT.