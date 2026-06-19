# Deployment

This site deploys automatically to S3 + CloudFront when changes are pushed to the `main` branch.

## How it works

A GitHub Actions workflow (`.github/workflows/deploy.yml`) triggers on every push to `main`. It:

1. Checks out the code
2. Assumes an AWS IAM role via OIDC (no stored credentials)
3. Uploads `index.html` to `s3://bettonbrewhouse-com/`
4. Uploads `robots.txt` and `sitemap.xml` with `Cache-Control: max-age=86400, public` (24-hour cache)
5. Syncs `images/` to `s3://bettonbrewhouse-com/images/` with `Cache-Control: max-age=31536000, public` (1-year cache)
6. Invalidates the CloudFront distribution (`E325XGV5XOOLEF`)

Only the `main` branch can trigger deployment. Feature branches and PRs do not deploy.

## IAM setup (one-time)

The workflow assumes an IAM role via GitHub's OIDC provider.

### Configuring IAM to trust GitHub

To use GitHub's OIDC provider, you must first set up federation in your AWS account. This involves creating an IAM Identity Provider that trusts GitHub's OIDC endpoint. You can create an IAM Identity Provider in the AWS Management Console by specifying the following details:

- Provider Type: `OIDC`
- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

### 1. Create the IAM role

In the AWS Console, go to **IAM > Roles > Create role**:

- **Trusted entity**: Web identity
- **Identity provider**: `token.actions.githubusercontent.com`
- **Audience**: `sts.amazonaws.com`

Then click **Next** and add the policy from step 2 below. Name the role `bettonbrewhouse-deploy`.

Alternatively, create the role via CLI:

```bash
aws iam create-role \
  --role-name bettonbrewhouse-deploy \
  --assume-role-policy-document file://trust-policy.json
```

Where `trust-policy.json` restricts access to `main` only:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::048044547730:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:roberthodgen/bettonbrewhouse-com:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

The `StringEquals` condition on `sub` ensures **only pushes to `main`** can assume this role. Feature branches, forks, and pull requests are blocked.

### 2. Attach the IAM policy

Attach this inline policy to the `bettonbrewhouse-deploy` role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::bettonbrewhouse-com",
        "arn:aws:s3:::bettonbrewhouse-com/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::048044547730:distribution/E325XGV5XOOLEF"
    }
  ]
}
```

This is the minimum set of permissions: write to the S3 bucket and invalidate CloudFront. No read access to other resources, no admin access.

### 3. Verify

After creating the role, push a change to `main` and check **Actions > Deploy to S3 & CloudFront** in the GitHub UI. The job should complete in under 30 seconds.

## Manual deployment (fallback)

The `Makefile` is still available for local deployment using your AWS CLI profile:

```bash
make deploy
```

This uses the `personal-prod` AWS CLI profile and is useful if the GitHub Actions workflow is unavailable.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Role arn:aws:iam::...:bettonbrewhouse-deploy cannot be assumed` | Role doesn't exist or trust policy is wrong | Verify the role exists and the OIDC trust policy matches the repo/branch |
| `AccessDenied` on S3/CloudFront | Policy not attached or ARNs don't match | Double-check the bucket name and CloudFront distribution ID in the policy |
| Deploy succeeds but site hasn't changed | CloudFront cache not invalidated | Check the workflow logs for the invalidation step; CloudFront propagation can take a minute |
| Workflow doesn't trigger on push | Branch name mismatch | The workflow only triggers on `main` (not `master`). Ensure your default branch is named `main` |
