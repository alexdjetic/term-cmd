import json
import os
import subprocess
import sys

def get_config(config):
    # Extract the configuration values
    name = config["name"]
    image = config["image"]
    size = config["size"]
    cpu_cores = config.get("cpu_cores", 1)
    ram = config.get("ram", "2G")
    storage = config.get("storage", f"./{name}_storage")
    sound = config.get("sound", False)
    display = config.get("display", "gtk")
    enable_kvm = config.get("enable_kvm", True)
    redirect_ports = config.get("port", {})

    config_dict = {
        "name": name,
        "image": image,
        "size": size,
        "cpu_cores": cpu_cores,
        "ram": ram,
        "storage": storage,
        "sound": sound,
        "display": display,
        "enable_kvm": enable_kvm,
        "redirect_ports": redirect_ports
    }

    return config_dict

def create_disk(config_dict):
    name = config_dict["name"]
    size = config_dict["size"]
    storage = config_dict["storage"]

    # Create the disk image
    disk_path = f"{storage}/{name}.qcow2"
    subprocess.run(["qemu-img", "create", "-f", "qcow2", disk_path, str(size) + "G"])

def create_port_redirection(redirect_ports):
    port_redirections = []

    for host_port, vm_port in redirect_ports.items():
        port_redirections.extend(["-redir", f"tcp:{host_port}::{vm_port}"])

    return port_redirections

    subprocess.run(qemu_command)



# Check if the configuration file argument is provided
if len(sys.argv) < 2:
    print("Usage: python create_vm.py <config_file>")
    sys.exit(1)

# Get the configuration file name from the command-line argument
config_file = sys.argv[1]

# Load the configuration from the file
try:
    with open(config_file, "r") as file:
        config = json.load(file)
except FileNotFoundError:
    print(f"Configuration file '{config_file}' not found.")
    sys.exit(1)
except json.JSONDecodeError:
    print(f"Invalid JSON format in configuration file '{config_file}'.")
    sys.exit(1)

def create_vm(config):
    config_dict = get_config(config)

    # Extract the configuration values
    name = config_dict["name"]
    image = config_dict["image"]
    cpu_cores = config_dict["cpu_cores"]
    ram = config_dict["ram"]
    storage = config_dict["storage"]
    sound = config_dict["sound"]
    display = config_dict["display"]
    enable_kvm = config_dict["enable_kvm"]
    redirect_ports = config_dict["redirect_ports"]

    # Create the storage directory if it doesn't exist
    os.makedirs(storage, exist_ok=True)

    # Create the disk image
    disk_path = f"{storage}/{name}.qcow2"
    create_disk(config_dict)

    # Build the QEMU command
    qemu_command = [
        "qemu-system-x86_64",
        "-m", ram,
        "-smp", str(cpu_cores),
        "-hda", disk_path,
        "-cdrom", image,
        "-device", "virtio-scsi-pci",
        "-device", "virtio-net-pci",
        "-device", "ac97",
        "-display", display,
    ]
    # Enable KVM if specified
    if enable_kvm:
        qemu_command.extend(["-enable-kvm"])

    # Add port redirections if specified
    port_redirections = create_port_redirection(redirect_ports)
    qemu_command.extend(port_redirections)

    # Start the virtual machine
    subprocess.run(qemu_command)

# Create the virtual machine
create_vm(config)
