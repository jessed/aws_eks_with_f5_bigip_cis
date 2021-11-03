output "vpc_out"        { value = aws_vpc.main }
output "vpc_id"         { value = aws_vpc.main.id }
output "mgmt_subnet"    { value = aws_subnet.mgmt }
output "data_subnet"    { value = aws_subnet.data }
output "eks1_subnet"    { value = aws_subnet.eks1 }
output "eks2_subnet"    { value = aws_subnet.eks2 }
output "rtb_id"         { value = aws_default_route_table.rtb.id }

