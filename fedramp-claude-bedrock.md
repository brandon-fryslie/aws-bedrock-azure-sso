In a nutshell: AWS GovCloud (US) already runs Amazon Bedrock under FedRAMP High / DoD IL-4/5 authorization; Anthropic’s Claude Code with Sonnet 3.7 is one of the approved models. To stay compliant, (1) keep all traffic and data inside GovCloud via PrivateLink VPC endpoints, (2) invoke only the FedRAMP-cleared model ARNs, (3) encrypt everything with KMS-CMKs you control, and (4) turn on CloudTrail + Bedrock model-invocation logging for full auditability.  The IAM mechanics are identical to commercial AWS, but every resource—account, role, log, bucket—must live in us-gov-west-1 or us-gov-east-1, and only U.S.-person principals may be granted access.  ￼ ￼

⸻

1. Enable model access in GovCloud
    1.	Log in to the GovCloud Bedrock console → Model access → request “Anthropic Claude 3.7 Sonnet (Code)”. Approval is instant if your account already passed US-persons screening.  ￼ ￼
    2.	Note the model ID ― e.g. us.anthropic.claude-3-7-sonnet-20250219-v1:0. This ID is embedded in the ARN you will allow.  ￼
    3.	If using multiple GovCloud accounts, link them through the Bedrock Foundation-model access workflow so only cleared accounts can invoke Claude.  ￼

⸻

2. IAM policy skeleton (GovCloud)

{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "InvokeClaudeCodeSonnet37",
"Effect": "Allow",
"Action": [
"bedrock:InvokeModel",
"bedrock:InvokeModelWithResponseStream"
],
"Resource": "arn:aws-us-gov:bedrock:us-gov-west-1::foundation-model/us.anthropic.claude-3-7-sonnet-*"
},
{
"Sid": "DiscoverAndLog",
"Effect": "Allow",
"Action": [
"bedrock:ListFoundationModels",
"bedrock:GetFoundationModel",
"bedrock:GetModelInvocationLoggingConfiguration"
],
"Resource": "*"
},
{
"Sid": "CloudWatchAndCloudTrailRead",
"Effect": "Allow",
"Action": [
"logs:DescribeLogGroups","logs:GetLogEvents",
"cloudwatch:GetMetricData","cloudtrail:LookupEvents"
],
"Resource": "*"
}
]
}

— Region prefix is arn:aws-us-gov: (not arn:aws:).
— Add an SCP or permission‐boundary that denies access outside GovCloud and requires principals tagged {"USPerson":"true"} to satisfy FedRAMP personnel rules.  ￼

⸻

3. Network & data-in-transit controls

Control	GovCloud requirement	How to satisfy
Private transport	No traffic may leave GovCloud boundary	Create an Interface VPC Endpoint (com.amazonaws.us-gov-west-1.bedrock-runtime) so calls never traverse the public Internet.  ￼
TLS 1.2+	FedRAMP High mandates FIPS-validated crypto	SDKs in GovCloud automatically negotiate TLS 1.2.
At-rest encryption	CMK-backed SSE everywhere	Use customer-managed KMS keys for CloudWatch Logs, S3, and invocation-logging buckets.  ￼


⸻

4. Logging & audit
   •	Model-invocation logging: Turn it on in Bedrock Settings; choose “CloudWatch Logs” and/or encrypted S3.  ￼
   •	CloudTrail captures Bedrock API calls for role-level auditing.
   •	Retain logs ≥ 90 days (FedRAMP SA-11). Use AWS Config FedRAMP packs for guardrails.  ￼

⸻

5. Sample Python (Boto3) call inside GovCloud

import boto3, json, os

bedrock = boto3.client(
"bedrock-runtime",
region_name="us-gov-west-1",  # FedRAMP boundary
endpoint_url="https://bedrock-runtime.us-gov-west-1.amazonaws.com"  # optional if VPC endpoint DNS enabled
)

resp = bedrock.invoke_model(
modelId="us.anthropic.claude-3-7-sonnet-20250219-v1:0",
accept="application/json",
contentType="application/json",
body=json.dumps({
"anthropic_version": "bedrock-2023-05-31",
"max_tokens": 1024,
"temperature": 0.1,
"messages": [
{"role": "user", "content": "Write an RFC-compliant IPv6 ping utility in Go"},
{"role": "assistant", "content": ""}
]
})
)
print(json.loads(resp["body"].read())["content"])

This uses the same Bedrock Runtime API shown in the AWS code library but points to the GovCloud endpoint.  ￼

⸻

6. Compliance quick-check

   Yes/No
   Account, IAM roles, KMS keys, logs all reside in GovCloud?
   VPC Interface Endpoint for bedrock-runtime enabled and restricted with SCBs?
   Model invocation logging + CloudTrail turned on and encrypted?
   SCPs block non-US-persons and deny Bedrock in commercial regions?
   Data classification & retention documented in SSP?

Meeting those items aligns invocation of Claude Code Sonnet 3.7 with FedRAMP High / DoD IL-4/5 controls while leveraging Bedrock’s fully managed security envelope.
