# Name of the key-pair to generate
variable "key_name" {
    type = string

    default = "ec2-ssh-key"
    description = "key-pair filename"
}

# https://cloud-images.ubuntu.com/locator/ec2/      <~ locate ami

variable "db_ec2" {
    type = object({
        ami_type = string
        instance_type = string
        location = string
    })

    default = {
        ami_type = "ami-072d6c9fae3253f26"          # us-east-1, Ubuntu 20.04
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
        ami_type = "ami-06334a6e92bb3f864"          # us-east-1, Ubuntu 20.04
        instance_type = "t3.medium"
        location = "us-east-1"
    }
    description = "EC2 instance type for control node"
}

# https://cloud-images.ubuntu.com/locator/ec2/
variable "worker_nodes_ec2" {
    type = object({
        ami_loc_types = list(object({
            ami_type = string
            location = string
        }))
        instance_type = string
    })

    default = {
        ami_loc_types = [
            {
                ami_type = "ami-0cb81cb394fc2e305"
                location = "us-east-2"
            },
            {
                ami_type = "ami-0ff4dd898acfb0e67"
                location = "us-west-1"
            }
        ]
        instance_type = "t2.small"
    }
    description = "EC2 instance type for worker nodes"
}
