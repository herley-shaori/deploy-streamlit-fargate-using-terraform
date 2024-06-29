resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRoleForStreamlitDeployment"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

data "aws_caller_identity" "current" {}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecr_specific_repo" {
  name        = "ECRSpecificRepoPolicy"
  description = "Policy to access specific ECR repository"
  depends_on  = [aws_ecr_repository.my_repository]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.my_repository.name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_specific_repo_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecr_specific_repo.arn
}

resource "aws_iam_role_policy_attachment" "s3_full_access_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name                   = "my-container"
    image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.my_repository.name}:latest"
    essential              = true
    portMappings           = [{
      containerPort        = 80
      hostPort             = 80
      protocol             = "tcp"
    }]
  }])
  execution_role_arn      = aws_iam_role.ecs_task_execution.arn
  task_role_arn           = aws_iam_role.ecs_task_execution.arn
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name        = "my-ecs-cluster"
  depends_on  = [aws_ecs_task_definition.task]

}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name      = "ecs_sg"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic from the world. This is bad practice. You would not want this in production."
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic to the world."
  }
}

# ECS Service - Run only after the image pushed into ECR.
#resource "aws_ecs_service" "service" {
#  name               = "my-ecs-service-streamlit"
#  cluster            = aws_ecs_cluster.main.id
#  task_definition    = aws_ecs_task_definition.task.arn
#  desired_count      = 1
#  launch_type        = "FARGATE"
#  network_configuration {
#    subnets          = aws_subnet.public[*].id
#    security_groups  = [aws_security_group.ecs_sg.id]
#    assign_public_ip = true
#  }
#}