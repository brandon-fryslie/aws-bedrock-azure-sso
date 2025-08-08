# ABAC (Attribute-Based Access Control) Configuration
# Optional configuration for attribute-based access control

# ABAC-enabled permission set for Department-based access
resource "aws_ssoadmin_permission_set" "abac_department_access" {
  count = var.enable_abac ? 1 : 0
  
  name             = "ABACDepartmentAccess"
  description      = "ABAC permission set using department attributes"
  instance_arn     = module.aws_commercial_identity_center.instance_arn
  session_duration = "PT2H"
  
  tags = merge(var.common_tags, {
    Type = "ABAC"
    AccessControl = "Department"
  })
}

# ABAC inline policy for department-based access
resource "aws_ssoadmin_permission_set_inline_policy" "abac_department_policy" {
  count = var.enable_abac ? 1 : 0
  
  instance_arn       = module.aws_commercial_identity_center.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.abac_department_access[0].arn
  
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::company-${aws:PrincipalTag/Department}/*"
        Condition = {
          StringEquals = {
            "s3:ExistingObjectTag/Department" = "${aws:PrincipalTag/Department}"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Department" = "${aws:PrincipalTag/Department}"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/department/${aws:PrincipalTag/Department}/*"
      }
    ]
  })
}

# ABAC permission set for Title-based access
resource "aws_ssoadmin_permission_set" "abac_title_access" {
  count = var.enable_abac ? 1 : 0
  
  name             = "ABACTitleAccess"
  description      = "ABAC permission set using title attributes"
  instance_arn     = module.aws_commercial_identity_center.instance_arn
  session_duration = "PT4H"
  
  tags = merge(var.common_tags, {
    Type = "ABAC"
    AccessControl = "Title"
  })
}

# ABAC inline policy for title-based access
resource "aws_ssoadmin_permission_set_inline_policy" "abac_title_policy" {
  count = var.enable_abac ? 1 : 0
  
  instance_arn       = module.aws_commercial_identity_center.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.abac_title_access[0].arn
  
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:ListRoles",
          "iam:ListPolicies"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/Title" = [
              "Regional Admin",
              "System Administrator",
              "Security Admin"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/Title" = "Analyst"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "billing:ViewBilling",
          "billing:ViewAccount"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/Department" = "Finance"
          }
        }
      }
    ]
  })
}

# Enable attributes for access control in both environments
resource "aws_ssoadmin_instance_access_control_attributes" "commercial_abac" {
  count = var.enable_abac ? 1 : 0
  
  instance_arn = module.aws_commercial_identity_center.instance_arn
  
  attribute {
    key = "Department"
    value {
      source = ["${path:enterprise.department}"]
    }
  }
  
  attribute {
    key = "Title"
    value {
      source = ["${path:enterprise.title}"]
    }
  }
}

resource "aws_ssoadmin_instance_access_control_attributes" "govcloud_abac" {
  count = var.enable_abac ? 1 : 0
  
  instance_arn = module.aws_govcloud_identity_center.instance_arn
  
  attribute {
    key = "Department"
    value {
      source = ["${path:enterprise.department}"]
    }
  }
  
  attribute {
    key = "Title"
    value {
      source = ["${path:enterprise.title}"]
    }
  }
}