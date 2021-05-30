# Add a VM with Ubuntu client via terraform and make some configuration changes.

provider "vsphere" {
  user           = "admin"
  password       = " Iwiiap@13ns"
  vsphere_server = "10.241.110.12"

  # If no self-signed cert
  allow_unverified_ssl = false
}

data "vsphere_datacenter" "dc" {
  name = "dc1"
}

data "vsphere_datastore" "datastore" {
  name          = "dc1_datastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "VSRE"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM-Net"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template"{
	name = var.template
	datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "ubuntu_instance" {
  name             = "myguestvm1"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 8096
  guest_id = data.vsphere_virtual_machine.template.guest_id
  folder = var.dc1/testvm/myguestvm1
  
  wait_for_guest_net_timeout = var.wait_for_guest_net_timeout

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 120
  }
  
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  
  clone{
    template_uuid = data.vsphere_virtual_machine.template.id
  }
  
provider "postgresql" {
    host = myguestvm1
	port = 23456
	database = test_db
	username = "user1"
    password = "Slkcpal@35"
	sslmode = "require"	
}

resource "postgresql_database" "db_default_instance_name"{
	name = PGRE_DB
	table = default
	scheme = <<EOF 
	    [
		    {
			"vsphere user" = "admin"
			"vsphere password" = "Iwiiap@13ns"
			"vsphere server" = "10.241.110.12"
			"VM path" = "dc1/testvm/myguestvm1"
			"Number of CPU" = "4"
			"Memory = 8 GB"
			"HDD" = "120 GB
			"Datacenter" = "dc1"
			"datastore" = "dc1_datastore"
			}
		]
	EOF
}
