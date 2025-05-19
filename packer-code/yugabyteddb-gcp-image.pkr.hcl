packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

source "googlecompute" "yugabytedb" {
  project_id          = "extreme-passkey-453707-n4"
  source_image_family = "rhel-9"
  subnetwork          = "yugabyte-subnet"
  service_account_email = "navya-407@extreme-passkey-453707-n4.iam.gserviceaccount.com"
  region              = "asia-south1"
  zone                = "asia-south1-b"
  ssh_username        = "yugabyte-user"
  machine_type        = "e2-standard-2"
  image_name          = "latest-yugabytedb-ami-{{timestamp}}"
  image_family        = "yugabytedbfamily"
  disk_size           = 50
  disk_type           = "pd-ssd"
  tags                = ["yugabyte-server"]
  scopes              = ["https://www.googleapis.com/auth/cloud-platform"]
}

build {
  sources = ["source.googlecompute.yugabytedb"] 

  # Step 1: Set up user 
  provisioner "shell" {
  inline = [
    "sudo dnf update -y",
    "sudo dnf install -y curl wget tar chrony openssh-server openssh-clients",
    "echo 'Creating yugabyte-user if it does not exist...'",
    
    "sudo id -u yugabyte-user &>/dev/null || sudo useradd -m yugabyte-user",
    "password=$(gcloud secrets versions access latest --secret=yugabyte-password)",
    "echo \"yugabyte-user:$password\" | sudo chpasswd",
    "sudo usermod -aG wheel yugabyte-user",
    "echo 'yugabyte-user ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/yugabyte-user"
  ]
}

  # Step 2: Run Ansible playbook
  provisioner "ansible" {
    playbook_file    = "/home/dopadm/packer-bank/packer/main.yaml"
    use_proxy        = false
  }
}
 
