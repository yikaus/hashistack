job "fabio" {
  region = "us-east-1"
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      driver = "exec"
      config {
        command = "fabio-1.3.4-go1.7.3-linux_amd64"
      }

      artifact {
        source = "https://github.com/eBay/fabio/releases/download/v1.3.4/fabio-1.3.4-go1.7.3-linux_amd64"
        options {
          checksum = "sha256:ae98704f524a678d19641bfaaea3cd73040507e47b3bda3fff911fb7fd42a83d"
        }
      }

      resources {
        cpu = 500
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = 9999
          }
          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}
