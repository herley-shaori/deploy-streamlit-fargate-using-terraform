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