/*
Не обращайте внимание на 23 порт, так как я многими способами пытался установить связь с VM. Это просто последняя версия сохраненного документа, поэтому я ничего и не менял.

Terraform v0.14.3
*/

#Connecting provider AWS
provider "aws" {
	access_key = "AKIA4DREQJM3E4FDQK7T" #Deleted for Security
	secret_key = "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" #Deleted for Security
	region = "eu-central-1"
}



#Creating VPC
resource "aws_vpc" "MyVPC" {
	cidr_block = "${var.vpc_cidr}"
	enable_dns_hostnames = true

	tags = {
		Name = "TF:VPC"
		Owner = "k.vasiliev32@gmail.com"
		Description = "Custom VPC"
	}
}



#Public subnet A for eu-central-1a
resource "aws_subnet" "aws-subnet-publicA" {
	vpc_id = "${aws_vpc.MyVPC.id}"
	cidr_block = "${var.vpc_cidrA}"
	availability_zone = "eu-central-1a"
	tags = {
		Name = "Subnet A"
	}
}



#Public subnet B for eu-central-1b
resource "aws_subnet" "aws-subnet-publicB" {
	vpc_id = "${aws_vpc.MyVPC.id}"
	cidr_block = "${var.vpc_cidrB}"
	availability_zone = "eu-central-1b"
	tags = {
		Name = "Subnet B"
	}
}



#Gateway for Internet
resource "aws_internet_gateway" "gw" {
	vpc_id = "${aws_vpc.MyVPC.id}"
}



#Security Group for VMs
resource "aws_security_group" "SecGroup" {
	name = "TCPGroup"
	vpc_id = "${aws_vpc.MyVPC.id}"
}



#Rules for Security Group
resource "aws_security_group_rule" "rules" {
	type = "ingress"
	from_port = 0
	to_port = 65535
	protocol = "TCP"
	cidr_blocks = ["0.0.0.0/0"]
	security_group_id = "${aws_security_group.SecGroup.id}"
}



#VM-1 at eu-central-1a with installed Windows Server 2019, Security Group, subnet A and key for connection
resource "aws_instance" "my-instance1" {
	ami = "${var.ami}"
	instance_type = "${var.instance_type}"
	availability_zone = "${var.az[0]}"
	subnet_id = "${aws_subnet.aws-subnet-publicA.id}"
	security_groups = ["${aws_security_group.SecGroup.id}"]
	key_name = "test1"

	tags = {
		Name = "VM-1"
	}
}



#VM-2 at eu-central-1b with installed Windows Server 2019, Security Group, subnet B and key for connection
resource "aws_instance" "my-instance2" {
	ami = "${var.ami}"
	instance_type = "${var.instance_type}"
	availability_zone = "${var.az[1]}"
	subnet_id = "${aws_subnet.aws-subnet-publicB.id}"
	security_groups = ["${aws_security_group.SecGroup.id}"]
	key_name = "test1"

	tags = {
		Name = "VM-2"
	}
}



#Network Load Balancer
resource "aws_lb" "MyNLB" {
	name = "MyNLB"
	internal = false
	load_balancer_type = "network"
	enable_cross_zone_load_balancing = true
	subnets = [aws_subnet.aws-subnet-publicB.id, aws_subnet.aws-subnet-publicA.id]
}



#Target Group
resource "aws_lb_target_group" "Target" {
	name = "TargetVMs"
	port = 23
	protocol = "TCP"
	vpc_id = aws_vpc.MyVPC.id
}



#Listener for Network Load Balancer
resource "aws_lb_listener" "Listener" {
	load_balancer_arn = aws_lb.MyNLB.arn
	protocol = "TCP"
	port = 23

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.Target.arn
	}
}



#Target Group Attachment for VM-1
resource "aws_lb_target_group_attachment" "attach1" {
	target_group_arn = aws_lb_target_group.Target.arn
	target_id = aws_instance.my-instance1.id
	port = 23
}



#Target Group Attachment for VM-2
resource "aws_lb_target_group_attachment" "attach2" {
	target_group_arn = aws_lb_target_group.Target.arn
	target_id = aws_instance.my-instance2.id
	port = 23
}



#Elastic IP for VM-1, because subnet A has only private IP
resource "aws_eip" "lb1" {
	instance = "${aws_instance.my-instance1.id}"
	vpc = true
}



#Elastic IP for VM-2, because subnet B has only private IP
resource "aws_eip" "lb2" {
	instance = "${aws_instance.my-instance2.id}"
	vpc = true
}