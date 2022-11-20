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
# AWS EC2 Instances
# -----------------------------------------------------------------------------

variable "db_ec2" {
    type = object({
        ami_type = string
        instance_type = string
        location = string
    })

    default = {
        ami_type = "${data.aws_ami.ubuntu.id}"
        instance_type = "t3.medium"
        location = "us-east-1"
    }
    description = "EC2 instance type for DB server"
}

variable "control_node_ec2" {
    type = object({
        ami_type = string
        instance_type = string
        location = string
    })

    default = {
        ami_type = "${data.aws_ami.ubuntu.id}"
        instance_type = "t3.medium"
        location = "us-east-1"
    }
    description = "EC2 instance type for control node"
}

# https://cloud-images.ubuntu.com/locator/ec2/
variable "worker_nodes_ec2" {
    type = object({
        instance_type = string
        ami_loc_types = list(object({
            ami_type = string
            location = string
        }))
    })

    default = {
        instance_type = "t2.medium"
        ami_loc_types = [
            {
                ami_type = "${data.aws_ami.ubuntu.id}"
                location = "us-east-1"
            },
            {
                ami_type = "${data.aws_ami.ubuntu.id}"
                location = "us-east-1"
            }
        ]
    }
    description = "EC2 instance type for worker nodes"
}
