locals {
    private_subnets = {
        for idx, cidr in var.private_subnet_cidrs:
        idx => { cidr=cidr, az = var.azs[idx]}
    }
}

resource "aws_subnet" "private" {
    for_each = local.private_subnets

    vpc_id = aws_vpc.this.id
    cidr_block = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = false
    
    tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-${each.key}"
    Tier = "private"
    })
}

resource "aws_eip" "nat" {
    count = var.create_nat && var.single_nat_gateway ? 1:0
    domain = "vpc"
    tags = merge(var.tags,{Name = "${var.name_prefix}-nat-eip"})
}

resource "aws_nat_gateway" "this" {
    count = var.create_nat && var.single_nat_gateway ? 1:0
    allocation_id = aws_eip.nat[0].id
    subnet_id = values(aws_subnet.public)[0].id
    depends_on = [aws_internet_gateway.igw]

    tags = merge(var.tags, { Name = "${var.name_prefix}-nat"})
}

resource "aws_route_table" "private" {
    count = length(aws_subnet.private) > 0 ? 1:0
    vpc_id = aws_vpc.this.id
    tags = merge (var.tags, {Name = "${var.name_prefix}-rtb-private"})
}

resource "aws_route" "private_default" {
  count = var.create_nat ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}