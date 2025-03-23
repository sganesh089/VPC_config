Below are notes for creating the VPC config for a new Account using terraform:

Below is Variable.tf file where we need to define all the variables:

In this example creating VPC named TEST.


variable "project_id" {
  type        = string
  description = "TEST creation"                       #Assign project name for this code (generic one for reference)
}
# Availability Zone

variable "syd_availability_zone" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["ap-southeast-2a", "ap-southeast-2b"]    #Define the avialbility zones as required
}
# VPC Name
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "TEST-vpc-01"                         #Define the VPC name
}
# VPC CIDR
variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
  default     = "10.50.0.0/16"                          #Define the VPC CIDR which needs to be unique
}
# Public Subnets CIDR
variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.50.1.0/24", "10.50.2.0/24"]          #Define the Public subnet CIDR which needs to be unique
}
# Private Subnets CIDR
variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.50.3.0/24", "10.50.4.0/24"]        #Define the Private subnet CIDR which needs to be unique
}

# Private Subnets Variables
variable "TEST_public_subnets" {
  description = "List of public subnet configurations"
  type = list(object({
     name = string
    cidr = string
    az   = string
  }))
  default = [
    { name = "TEST_Public Subnet 1", cidr = "10.40.1.0/24", az = "ap-southeast-2a" },    #Define the Public subnet name, cidr and AZ which needs to be unique
    { name = "TEST_Public Subnet 2", cidr = "10.40.2.0/24", az = "ap-southeast-2b" }      #Define the Public subnet name, cidr and AZ which needs to be unique
  ]
}
# Private Subnets Variables
 variable "TEST_private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    { name = "TEST_Private Subnet 1", cidr = "10.40.3.0/24", az = "ap-southeast-2a" },         #Define the Private subnet name, cidr and AZ which needs to be unique
    { name = "TEST_Private Subnet 2", cidr = "10.40.4.0/24", az = "ap-southeast-2b" }           #Define the Private subnet name, cidr and AZ which needs to be unique
  ]
}


# Internet Gateway Variables
 variable "igw_gtw" {
  description = "List of Internet Gateway configurations"
  type        = string
  default     = "TEST-igw"                                      # Define the internet gateway name
 }

# NatInternet Gateway Variables
 variable "nat_gateway_tags" {
  description = "List of NAT Gateway tags"
  type        = list(object({
    name = string
  }))
  default = [
    { name = "TEST-nat-gw-1" },                     # Define the NAT gateway name
    { name = "TEST-nat-gw-2" }                      # Define the NAT gateway name
  ]
}

# Public Route table Variables

variable "public_route_table_names" {
  description = "List of public route table names"
  type        = list(string)
  default     = ["TEST-public-rt-1", "TEST-public-rt-2"]            # Define the Public route tables name
}
# Private Route table Variables

variable "private_route_table_names" {
  description = "List of private route table names"
  type        = list(string)
  default     = ["TEST-private-rt-1", "TEST-private-rt-2"]               # Define the Private route tables name
}


# Transit Gateway Variables

variable "tgw_name" {
  description = "Name of the Transit Gateway"
  type        = string
  default     = "TEST-transit-gateway"                            # Define the Transit Gateway name
}

variable "tgw_description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Transit Gateway for connecting multiple VPCs"       # Default defenitions for the Transit Gateway name
}

variable "amazon_side_asn" {
  description = "Amazon side ASN for the Transit Gateway"
  type        = number
  default     = 64512                                                 # Default defenitions for the Transit Gateway name
}

variable "tgw_auto_accept_shared_attachments" {
  description = "Auto accept shared attachments"
  type        = string
  default     = "disable"                                        # Default defenitions for the Transit Gateway name
}

variable "tgw_default_route_table_association" {
  description = "Default route table association setting"
  type        = string
  default     = "enable"                                          # Default defenitions for the Transit Gateway name
}

variable "tgw_default_route_table_propagation" {
  description = "Default route table propagation setting"
  type        = string
  default     = "enable"                                               # Default defenitions for the Transit Gateway name
}

variable "tgw_dns_support" {
  description = "Enable or disable DNS support"
  type        = string
  default     = "enable"                                           # Default defenitions for the Transit Gateway name
}

variable "tgw_multicast_support" {
  description = "Enable or disable multicast support"
  type        = string
  default     = "disable"                                               # Default defenitions for the Transit Gateway name
}

variable "tgw_vpn_ecmp_support" {
  description = "Enable or disable ECMP support for VPN connections"
  type        = string
  default     = "enable"                                                   # Default defenitions for the Transit Gateway name
}



# Main Trasnit Gateway Variables

variable "transit_gateway_attachment_name" {
  description = "Name of the Transit Gateway Attachment"
  type        = string
  default     = "tgw-037b6a9f775cfe121"                                   # Define the master NETWORK account transit gateway ID for all the private traffic to pass via central transit gateway
}
