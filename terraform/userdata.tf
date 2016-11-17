
data "template_file" "client" {
    template = "${file("client.tpl")}"
    vars {
        region = "${var.aws_region}"
        domain = "${var.privateDNS}"
        nomad_version = "${lookup("version", "nomad")}"
    }
}


data "template_cloudinit_config" "clientconfig" {
  gzip          = false
  base64_encode = false
  
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.client.rendered}"
  }

}

data "template_file" "server" {
    template = "${file("server.tpl")}"
    vars {
        region = "${var.aws_region}"
        domain = "${var.privateDNS}"
        nomad_version = "${lookup("version", "nomad")}"
        vault_version = "${lookup("version", "vault")}"
        consul_version = "${lookup("version", "consul")}"
        
    }
}

data "template_cloudinit_config" "serverconfig" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.server.rendered}"
  }
}
