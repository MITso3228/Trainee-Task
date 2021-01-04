variable "ami" {
	default = "ami-01b65a06ec09db85c"
}

variable "instance_type" {
	default = "t2.micro"
}

variable "az" {
	type = list(string)
	default = ["eu-central-1a", "eu-central-1b"]
}

variable "vpc_cidr" {
	description = "CIDR for the whole VPC"
	default = "172.30.0.0/16"
}

variable "vpc_cidrA" {
	description = "CIDR for subnet A"
	default = "172.30.0.0/24"
}

variable "vpc_cidrB" {
	description = "CIDR for subnet B"
	default = "172.30.1.0/24"
}