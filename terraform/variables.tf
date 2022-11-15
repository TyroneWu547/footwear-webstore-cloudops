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
    })

    default = {
        ami_type = "ami-01d08089481510ba2"          # us-east-1, Ubuntu 20.04
        instance_type = "t2.medium"
    }
    description = "EC2 instance type for DB server"
}

variable "control_node_ec2" {
    type = object({
        ami_type = string
        instance_type = string
    })

    default = {
        ami_type = "ami-01d08089481510ba2"          # us-east-1, Ubuntu 20.04
        instance_type = "t2.micro"
    }
    description = "EC2 instance type for control node"
}

variable "worker_nodes_ec2" {
    type = object({
        ami_type = string
        instance_type = string
        instance_count = number
    })

    default = {
        instance_count = 1
        ami_type = "ami-01d08089481510ba2"          # us-east-1, Ubuntu 20.04 will change later to map? include different regions
        instance_type = "t2.micro"
    }
    description = "EC2 instance type for worker nodes"
}
