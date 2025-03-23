Below are notes for creating the VPC config for a new Account using terraform:

Below is Main.tf file where we need to define all the variables:

In this example creating VPC named TEST.


# Create AWS VPC in ap-southeast-02
# CIDR - 10.50.0.0/16
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr                                # create the VPC with the CIDR defined in the variable.tf file for VPC

  tags = {
    Name = var.vpc_name                                       # create the VPC with the name defined in the variable.tf file for VPC
  }
}

# Public Subnets Configuration

resource "aws_subnet" "public_subnets" {
  count = length(var.TEST_public_subnets)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.TEST_public_subnets[count.index].cidr             # creates both public subnets with the CIDR defined in the variable.tf file for VPC
  availability_zone = var.TEST_public_subnets[count.index].az               # creates both public subnets in the defined availability zones with the name defined in the variable.tf file for VPC

  tags = {
    Name = var.TEST_public_subnets[count.index].name                        # creates both public subnets with the name defined in the variable.tf file for VPC         
  }
}

# Private Subnets Configuration
resource "aws_subnet" "private_subnets" {
  count = length(var.TEST_private_subnets)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.TEST_private_subnets[count.index].cidr           # creates both private subnets with the CIDR defined in the variable.tf file for VPC
  availability_zone = var.TEST_private_subnets[count.index].az           # creates both Private subnets in the defined availability zones with the name defined in the variable.tf file for VPC


  tags = {
    Name = var.TEST_private_subnets[count.index].name                   # creates both private subnets with the name defined in the variable.tf file for VPC  
  }
}

# Internet Gateway config

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id                                        # defines the vpc to which the internet gateway needs to be attached  

  tags = {
    Name = var.igw_gtw                                              # defines the internet gatewar name
  }
}

# Elastic IP config

resource "aws_eip" "nat_eip" {
  count = length(var.cidr_private_subnet)                            # Create random elastic IPs to be attacheds to all the private subnets  
  vpc = true
}

# NAT gateway config
resource "aws_nat_gateway" "nat_gateway" {
  count      = length(var.cidr_private_subnet)                      # Create NAT gateways as per each private subnet  
  depends_on = [aws_eip.nat_eip]                                    # Assigns elastic IPs created in last step to NAT gateways  

  allocation_id = aws_eip.nat_eip[count.index].id                   # Allocates elastic IPs created in last step to NAT gateways  
  subnet_id     = aws_subnet.private_subnets[count.index].id          # Assigns the NAT gateway to private subnets  


  tags = {
    Name = var.nat_gateway_tags[count.index].name                        # Assigns the NAT gateway name as per the private subnets
  }
}

# Public Route table config

resource "aws_route_table" "public_route_table" {
  count  = length(var.public_route_table_names)                           # Deside the count of the Public route table
  vpc_id = aws_vpc.main_vpc.id                                            # Link with the VPC

  route {
    cidr_block = "0.0.0.0/0"                                               # Assign CIDR to access internet from public subnets
    gateway_id = aws_internet_gateway.main_igw.id                         # Assign Internet gateway to public subnets
  }

  tags = {
    Name = var.public_route_table_names[count.index]                     # Assign public route table names
  }
}

# Private Route table config

resource "aws_route_table" "private_route_table" {
  count      = length(var.private_route_table_names)                      # Deside the count of the Private route table
  vpc_id     = aws_vpc.main_vpc.id                                        # Link with the VPC
  depends_on = [aws_nat_gateway.nat_gateway]

  route {
    cidr_block      = "0.0.0.0/0"                                        # Assign CIDR to access internet from NAT gateway
    nat_gateway_id  = aws_nat_gateway.nat_gateway[count.index].id         # Assign Nat gateway to priavte subnets
  }

  tags = {
    Name = var.private_route_table_names[count.index]                    # Assign private route table names
  }
}

# Route table association - Public Subnet

resource "aws_route_table_association" "public_subnet_asso" {
  count = length(var.cidr_public_subnet)                                         # Deside the count of the public subnet associations depending on the count of public subnets

  depends_on = [aws_subnet.public_subnets, aws_route_table.public_route_table]

  subnet_id      = aws_subnet.public_subnets[count.index].id                         # Deside the  public subnets and their IDs
  route_table_id = aws_route_table.public_route_table[count.index].id                # Deside the  public route table and their IDs
}

# Route table association - Private Subnet

resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.cidr_private_subnet)                                     # Deside the count of the Private subnet associations depending on the count of private subnets

  depends_on = [
    aws_subnet.private_subnets,
    aws_route_table.private_route_table
  ]

  subnet_id      = aws_subnet.private_subnets[count.index].id                  # Deside the  private subnets and their IDs
  route_table_id = aws_route_table.private_route_table[count.index].id          # Deside the  private route table and their IDs
}

# Transit Gateway config

resource "aws_ec2_transit_gateway" "main_tgw" {                                    # Assign default values for TGW from variables.tf
  description                     = var.tgw_description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.tgw_auto_accept_shared_attachments
  default_route_table_association = var.tgw_default_route_table_association
  default_route_table_propagation = var.tgw_default_route_table_propagation
  dns_support                     = var.tgw_dns_support
  multicast_support               = var.tgw_multicast_support
  vpn_ecmp_support                = var.tgw_vpn_ecmp_support

  tags = {
    Name = var.tgw_name                                                          # Assign TGE name from variables.tf
  }
}

# Accept Main Transit Gateway from Main Network account

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  transit_gateway_id = var.transit_gateway_attachment_name                        # Master NETWORK account transit gateway ID to route private subnet traffic to the internet 
  vpc_id             = aws_vpc.main_vpc.id                                       #current VPC ID
  subnet_ids = aws_subnet.private_subnets[*].id                                  #current VPC private subnets

  tags = {
    Name = "TEST-TGW-Attachment"
  }
}
