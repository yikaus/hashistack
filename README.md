## HashiStack on AWS

This repo is inspired by [kelseyhightower/hashiconf-eu-2016](https://github.com/kelseyhightower/hashiconf-eu-2016) to create hashistack(Consul/Nomad/Vault) cluster over AWS , easy bootstrap compare with  kelseyhightower's original one . 

### Example setup
```
1 VPC
3 server subnet over 3 aws zone
3 client subnet over 3 aws zone
1 autoscaling group cross 3 aws zone and 3 server instances in each zone , fixed size
1 autoscaling group to  nomad client/agents , user can defined ASG size for nomad
```
Above subnets are all public and only accessed from your desktop public ip , you need setup your ip in `dev.tfvars.example` , version also can be customized, see below 

```
aws_region = "us-east-1"
key_name = "test.key"
availability_zones = "us-east-1b,us-east-1c,us-east-1d"
vpc_cidr_block = "172.31.0.0/16"
#debian 8
aws_amis = {
  "us-east-1" = "ami-116d857a"
}

version = {
  nomad = "0.5.0"
  consul = "0.7.1"
  vault = "0.6.2"
  hashistack = "0.2.0"
}

server_instance_type = "t2.nano"
client_instance_type = "t2.nano"
asg_min = "1"
asg_max = "1"
asg_desired = "1"

privateDNS = "dev.local"

#get my ip : dig +short myip.opendns.com @resolver1.opendns.com
my_ip = "<your_IP_here>/32"
```

### Bootstrap
clone this repo
```
cd terraform
```

Generate ddns lambda function
```
zip -rj lambda_function_ddns.zip ../functions/ddns/*
```

edit [dev.tfvars.example](terraform/dev.tfvars.example) , update my_ip to your public ip/sshkey and other variable if needed.

```
terraform plan -var-file=dev.tfvars.example
terraform apply -var-file=dev.tfvars.example
```

You should able to see something like below output when terraform provision finished .

```
Outputs:

CONSUL_UI_ADDR = http://server-elb-000000000.us-east-1.elb.amazonaws.com:8500/ui
NOMAD_ADDR = http://server-elb-000000000.us-east-1.elb.amazonaws.com:4646
VAULT_ADDR = http://server-elb-000000000.us-east-1.elb.amazonaws.com:8200
```

### To Use

Access consul UI
`<CONSUL_UI_ADDR>`

Use Vault
```
export VAULT_ADDR=<VAULT_ADDR>
vault init
vault unseal
vault auth <root-token>
```
Run two system jobs
```
export NOMAD_ADDR=<NOMAD_ADDR>
```
make sure nodes are all ready

`nomad node-status`

As there is an issue with memory.limit_in_bytes issue on debian8 , I add reboot in userdata , it will make node up become slow as it needs reboot for the first time . If you choose ubuntu or other host os , you can just remove fix from [client.sh](userdata/client.sh) 
```
cd jobs
nomad run consul.nomad
nomad run fabio.nomad
```


### Licnese
MIT.