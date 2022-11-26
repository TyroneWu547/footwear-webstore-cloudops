# -----------------------------------------------------------------------------
# Private Key-pair
# -----------------------------------------------------------------------------

# Name of the key-pair to generate
variable "key_name" {
    type = string

    default = "ec2-ssh-key"
    description = "key-pair filename"
}

# -----------------------------------------------------------------------------
# AWS Security Groups
# -----------------------------------------------------------------------------

variable "nodeport_ports" {
    type = list(object({
        description = string
        port = number
    }))

    default = [
        { 
            description = "Inbound for Route microservice", 
            port = 30000 
        },
        { 
            description = "Inbound for Buy microservice", 
            port = 30001 
        },
        { 
            description = "Inbound for Display microservice", 
            port = 30002 
        },
        { 
            description = "Inbound for microk8s dashboard", 
            port = 31000 
        }
    ]
}

variable "microk8s_node_network_ports" {
    type = list(object({
        description = string
        port = number
        protocol = string
    }))

    default = [
        { description = "microk8s api-server", port = 16443, protocol = "tcp" },
        { description = "microk8s kubelet", port = 10250, protocol = "tcp" },
        { description = "microk8s kubelet", port = 10255, protocol = "tcp" },
        { description = "microk8s cluster-agent", port = 25000, protocol = "tcp" },
        { description = "microk8s etcd", port = 12379, protocol = "tcp" },
        { description = "microk8s kube-controller", port = 10257, protocol = "tcp" },
        { description = "microk8s kube-scheduler", port = 10259, protocol = "tcp" },
        { description = "microk8s dqlite", port = 19001, protocol = "tcp" },
        { description = "microk8s calico", port = 4789, protocol = "udp" }
    ]
}

# -----------------------------------------------------------------------------
# AWS EC2 Instances
# -----------------------------------------------------------------------------

variable "db_ec2" {
    type = object({
        # ami_type = string
        instance_type = string
        location = string
    })

    default = {
        # ami_type = "${data.aws_ami.ubuntu.id}"
        instance_type = "t2.large"
        location = "us-east-1"
    }
    description = "EC2 instance type for DB server"
}

variable "control_node_ec2" {
    type = object({
        # ami_type = string
        instance_type = string
        location = string
    })

    default = {
        # ami_type = "${data.aws_ami.ubuntu.id}"
        instance_type = "t2.medium"
        location = "us-east-1"
    }
    description = "EC2 instance type for control node"
}

# https://cloud-images.ubuntu.com/locator/ec2/
variable "worker_nodes_ec2" {
    type = object({
        instance_type = string
        ami_loc_types = list(object({
            # ami_type = string
            location = string
        }))
    })

    default = {
        instance_type = "t2.medium"
        ami_loc_types = [
            {
                # ami_type = "${data.aws_ami.ubuntu.id}"
                location = "us-east-1"
            },
            {
                # ami_type = "${data.aws_ami.ubuntu.id}"
                location = "us-east-1"
            }
        ]
    }
    description = "EC2 instance type for worker nodes"
}
