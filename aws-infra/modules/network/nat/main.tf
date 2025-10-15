# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  count      = 1
  depends_on = [var.igw_id]
}

# NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat" {
  count         = 1
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = var.public_subnet_ids[0]

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [var.igw_id]
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }

  tags = {
    Name = "private-rt"
  }
}

# Associate private route table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}