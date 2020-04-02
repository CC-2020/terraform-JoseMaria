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
