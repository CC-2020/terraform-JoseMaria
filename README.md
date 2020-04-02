# Tarea Terraform en Google Cloud Platform
En esta tarea de la asignatura "Cloud Computing" del Máster en Ingeniería Informática de la Universidad de Huelva se procederá a crear una infraestructura en **GCP** mediante la herramienta **Terraform**.


La infraestructura que se va a crear consiste en el despliegue de un servidor web. Dicho servidor web llevará instalado apache y php, y además se clonará este repositorio para realizar la copia del fichero web/pagina.php en el directorio /var/www/html del servidor. 
Se creará también una VPC donde se situará la instancia. Dicha VPC tendrá un firewall en el que habrá reglas de entrada que permitan la conexión SSH y HTTP al servidor web.

## Pasos a seguir
A continuación se van a detallar los pasos que se han seguido para poner en funcionamiento lo dicho.

## Instancia
Se ha decidido que la instancia tenga las siguientes características:
* **Tipo**: f1-micro.
* **S.O.**: Debian 9.
* **Red**: "my-network".
* **Firewall**: "firewall-instances".
* **Nombre**: "apache-vm".
* **Zona**: us-central1-a.

## Instalación Terraform
En el Cloud Shell de GCP viene instalado por defecto la herramienta Terraform, por lo que no ha sido necesario instalar nada. En caso de que sea necesario, a continuaciópn se muestran las instrucciones a ejecutar:

        $ sudo apt update
        $ sudo apt-get install wget unzip
        $ wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
        $ sudo unzip ./terraform_0.12.24_linux_amd64.zip -d /usr/local/bin/
   
   
## Creación ficheros configuración
Ahora creamos los ficheros de configuración (.tf) necesarios para crear la infraestructura deseada. En mi caso, he escrito en un fichero llamado 'main.tf' toda la configuración:

      $ nano main.tf

      //Se crea la instancia
      resource "google_compute_instance" "default" {
       project      = "<ID_INSTANCE>"
       name         = "apache-vm"
       machine_type = "f1-micro"
       zone         = "us-central1-a"


      //Se instalará el SO debian9
       boot_disk {
         initialize_params {
           image = "debian-cloud/debian-9"
         }
       }

      // Se instalará apache y php en la instancia... se creará un fichero text1.txt al inicio de la instalación y otro fichero test2.txt al final, para comprobar que se han ejecutado los comandos
       metadata_startup_script = "echo hi1 > test1.txt; sudo apt-get update; sudo apt-get install -yq apache2 php; sudo apt-get install -yq git; cd / && sudo git clone https://github.com/CC-2020/terraform-JoseMaria.git; sudo cp /terraform-JoseMaria/web/pagina.php /var/www/html; sudo chmod 666 /var/www/html/pagina.php; echo hi2 > test2.txt"

       network_interface {
         //Se conectara a la red que indicamos abajo
         network = google_compute_network.default.self_link

         access_config {
         }
       }
      }


      //Creamos las reglas del firewall
      resource "google_compute_firewall" "default"{
        project = "<ID_INSTANCE>"
        name    = "firewall-instances"
        network = google_compute_network.default.self_link
        priority = 65534

        allow {
          protocol = "icmp"
        }

        allow {
          protocol = "tcp"
          ports    = ["80", "22"]
        }

      }


      //Creamos la red
      resource "google_compute_network" "default" {
        project = "cc2020-271418"
        name = "my-network"
      }



## Iniciamos Terraform
Antes de utilizar terraform es necesario inicializarlo para que se descargue los plugins necesarios para trabajar con los proveedores y elementos definidos en los ficheros (.tf)
      
      $ terraform init
      
      Initializing the backend...
      Initializing provider plugins...
      - Checking for available provider plugins...
      - Downloading plugin for provider "google" (hashicorp/google) 3.15.0...
      The following providers do not have any version constraints in configuration,
      so the latest version was installed.
      To prevent automatic upgrades to new major versions that may contain breaking
      changes, it is recommended to add version = "..." constraints to the
      corresponding provider blocks in configuration, with the constraint strings
      suggested below.
      * provider.google: version = "~> 3.15"
      Terraform has been successfully initialized!
      You may now begin working with Terraform. Try running "terraform plan" to see
      any changes that are required for your infrastructure. All Terraform commands
      should now work.
      If you ever set or change modules or backend configuration for Terraform,
      rerun this command to reinitialize your working directory. If you forget, other
      commands will detect it and remind you to do so if necessary.
      
## Planear la Infraestructura
      $ terraform plan
      
      Refreshing Terraform state in-memory prior to plan...
      The refreshed state will be used to calculate this plan, but will not be
      persisted to local or remote state storage.
      ------------------------------------------------------------------------
      An execution plan has been generated and is shown below.
      Resource actions are indicated with the following symbols:
        + create
      Terraform will perform the following actions:
        # google_compute_firewall.default will be created
        + resource "google_compute_firewall" "default" {
            + creation_timestamp = (known after apply)
            + destination_ranges = (known after apply)
            + direction          = (known after apply)
            + id                 = (known after apply)
            + name               = "firewall-instances"
            + network            = (known after apply)
            + priority           = 65534
            + project            = "cc2020-271418"
            + self_link          = (known after apply)
            + source_ranges      = (known after apply)
            + allow {
                + ports    = [
                    + "80",
                    + "22",
                  ]
                + protocol = "tcp"
              }
        + allow {
                + ports    = []
                + protocol = "icmp"
              }
          }
        # google_compute_instance.default will be created
        + resource "google_compute_instance" "default" {
            + can_ip_forward          = false
            + cpu_platform            = (known after apply)
            + current_status          = (known after apply)
            + deletion_protection     = false
            + guest_accelerator       = (known after apply)
            + id                      = (known after apply)
            + instance_id             = (known after apply)
            + label_fingerprint       = (known after apply)
            + machine_type            = "f1-micro"
            + metadata_fingerprint    = (known after apply)
            + metadata_startup_script = "echo hi1 > test1.txt; sudo apt-get update; sudo apt-get install -yq apache2 php; sudo apt-get install -yq git; cd / && sudo git clone https://github.com/CC-202
      0/terraform-JoseMaria.git; sudo cp /terraform-JoseMaria/web/pagina.php /var/www/html; sudo chmod 666 /var/www/html/pagina.php; echo hi2 > test2.txt"
            + min_cpu_platform        = (known after apply)
            + name                    = "apache-vm"
            + project                 = "cc2020-271418"
            + self_link               = (known after apply)
            + tags_fingerprint        = (known after apply)
            + zone                    = "us-central1-a"
            + boot_disk {
                + auto_delete                = true
                + device_name                = (known after apply)
                + disk_encryption_key_sha256 = (known after apply)
                + kms_key_self_link          = (known after apply)
                + mode                       = "READ_WRITE"
                + source                     = (known after apply)
        + initialize_params {
                + image  = "debian-cloud/debian-9"
                + labels = (known after apply)
                + size   = (known after apply)
                + type   = (known after apply)
              }
          }

        + network_interface {
            + name               = (known after apply)
            + network            = (known after apply)
            + network_ip         = (known after apply)
            + subnetwork         = (known after apply)
            + subnetwork_project = (known after apply)

            + access_config {
                + nat_ip       = (known after apply)
                + network_tier = (known after apply)
              }
          }

        + scheduling {
            + automatic_restart   = (known after apply)
            + on_host_maintenance = (known after apply)
            + preemptible         = (known after apply)

            + node_affinities {
                + key      = (known after apply)
                + operator = (known after apply)
                + values   = (known after apply)
              }
          }
      }
      # google_compute_network.default will be created
          + resource "google_compute_network" "default" {
              + auto_create_subnetworks         = true
              + delete_default_routes_on_create = false
              + gateway_ipv4                    = (known after apply)
              + id                              = (known after apply)
              + ipv4_range                      = (known after apply)
              + name                            = "my-network"
              + project                         = "cc2020-271418"
              + routing_mode                    = (known after apply)
              + self_link                       = (known after apply)
            }
        Plan: 3 to add, 0 to change, 0 to destroy.
        ------------------------------------------------------------------------
        Note: You didn't specify an "-out" parameter to save this plan, so Terraform
        can't guarantee that exactly these actions will be performed if
        "terraform apply" is subsequently run.
      
## Aplica la Infraestructura
      $ terraform apply
      
      An execution plan has been generated and is shown below.
      Resource actions are indicated with the following symbols:
        + create

      Terraform will perform the following actions:

        # google_compute_firewall.default will be created
        + resource "google_compute_firewall" "default" {
            + creation_timestamp = (known after apply)
            + destination_ranges = (known after apply)
            + direction          = (known after apply)
            + id                 = (known after apply)
            + name               = "firewall-instances"
            + network            = (known after apply)
            + priority           = 65534
            + project            = "cc2020-271418"
            + self_link          = (known after apply)
            + source_ranges      = (known after apply)

            + allow {
                + ports    = [
                    + "80",
                    + "22",
                  ]
                + protocol = "tcp"
              }
            + allow {
                + ports    = []
                + protocol = "icmp"
              }
          }
        # google_compute_instance.default will be created
          + resource "google_compute_instance" "default" {
              + can_ip_forward          = false
              + cpu_platform            = (known after apply)
              + current_status          = (known after apply)
              + deletion_protection     = false
              + guest_accelerator       = (known after apply)
              + id                      = (known after apply)
              + instance_id             = (known after apply)
              + label_fingerprint       = (known after apply)
              + machine_type            = "f1-micro"
              + metadata_fingerprint    = (known after apply)
              + metadata_startup_script = "echo hi1 > test1.txt; sudo apt-get update; sudo apt-get install -yq apache2 php; sudo apt-get install -yq git; cd / && sudo git clone https://github.com/CC-202
        0/terraform-JoseMaria.git; sudo cp /terraform-JoseMaria/web/pagina.php /var/www/html; sudo chmod 666 /var/www/html/pagina.php; echo hi2 > test2.txt"
              + min_cpu_platform        = (known after apply)
              + name                    = "apache-vm"
              + project                 = "cc2020-271418"
              + self_link               = (known after apply)
              + tags_fingerprint        = (known after apply)
              + zone                    = "us-central1-a"
              + boot_disk {
                  + auto_delete                = true
                  + device_name                = (known after apply)
                  + disk_encryption_key_sha256 = (known after apply)
                  + kms_key_self_link          = (known after apply)
                  + mode                       = "READ_WRITE"
                  + source                     = (known after apply)
                  + initialize_params {
                      + image  = "debian-cloud/debian-9"
                      + labels = (known after apply)
                      + size   = (known after apply)
                      + type   = (known after apply)
                    }   
                }
              + network_interface {
                  + name               = (known after apply)
                  + network            = (known after apply)
                  + network_ip         = (known after apply)
                  + subnetwork         = (known after apply)
                  + subnetwork_project = (known after apply)
                  + access_config {
                      + nat_ip       = (known after apply)
                      + network_tier = (known after apply)
                    }
                }
              + scheduling {
                  + automatic_restart   = (known after apply)
                  + on_host_maintenance = (known after apply)
                  + preemptible         = (known after apply)
                  + node_affinities {
                      + key      = (known after apply)
                      + operator = (known after apply)
                      + values   = (known after apply)
                    }
                }
            }
        # google_compute_network.default will be created
              + gateway_ipv4                    = (known after apply)
              + id                              = (known after apply)
              + ipv4_range                      = (known after apply)
              + name                            = "my-network"
              + project                         = "cc2020-271418"
              + routing_mode                    = (known after apply)
              + self_link                       = (known after apply)
            }
        Plan: 3 to add, 0 to change, 0 to destroy.
        Do you want to perform these actions?
          Terraform will perform the actions described above.
          Only 'yes' will be accepted to approve.
          Enter a value: yes
        google_compute_network.default: Creating...
        google_compute_network.default: Still creating... [10s elapsed]
        google_compute_network.default: Still creating... [20s elapsed]
        google_compute_network.default: Still creating... [30s elapsed]
        google_compute_network.default: Still creating... [40s elapsed]
        google_compute_network.default: Creation complete after 43s [id=projects/cc2020-271418/global/
        networks/my-network]
        google_compute_instance.default: Creating...
        google_compute_firewall.default: Creating...
        google_compute_instance.default: Still creating... [10s elapsed]
        google_compute_firewall.default: Still creating... [10s elapsed]
        google_compute_firewall.default: Creation complete after 11s [id=projects/cc2020-271418/global
        /firewalls/firewall-instances]
        google_compute_instance.default: Still creating... [20s elapsed]
        google_compute_instance.default: Creation complete after 24s [id=projects/cc2020-271418/zones/
        us-central1-a/instances/apache-vm]
        Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

## Comprobación
Podemos ver que se ha creado la infraestructura. Podemos navegar a la dirección IP externa de la instancia creada: http://IP_EXTERNA/pagina.php
para comprobar el correcto funcionamiento del servidor web.
