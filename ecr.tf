# Create an ECR repository
resource "aws_ecr_repository" "my_repository" {
  name = "my-ecr-repo"

  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "my-ecr-repo"
  }
}

# Apply a lifecycle policy to keep only the latest image
resource "aws_ecr_lifecycle_policy" "my_repository_lifecycle_policy" {
  repository = aws_ecr_repository.my_repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only the latest image",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["latest"],
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# Output the ECR repository name
output "ecr_repository_name" {
  value = aws_ecr_repository.my_repository.name
}

# Write the ECR repository name to ecr_name.txt
resource "null_resource" "write_ecr_name" {
  provisioner "local-exec" {
    command = "echo ${aws_ecr_repository.my_repository.name} > ecr_name.txt"
  }

  # Ensure this runs after the ECR repository is created
  depends_on = [aws_ecr_repository.my_repository]
}