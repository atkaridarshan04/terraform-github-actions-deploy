# Complete Deployment Steps

## Prerequisites
- AWS CLI configured with admin permissions
- Terraform installed
- GitHub repository created
- Docker installed (for local testing)

## Step 1: Bootstrap Infrastructure (One-time setup)
```bash
cd bootstrap
terraform init
terraform apply
```
**Important**: Note the OIDC role ARN from the output - you'll need it for GitHub Actions.

## Step 2: Configure GitHub Repository Settings

### Enable GitHub Actions
1. Go to your GitHub repository
2. Navigate to Settings → Actions → General
3. Ensure "Allow all actions and reusable workflows" is selected

### Add GitHub Secrets
Go to Settings → Secrets and variables → Actions, add these secrets:

**Required Secrets:**
- `AWS_ACCOUNT_ID` - Your 12-digit AWS account ID
- `AWS_REGION` - `eu-north-1` (or your preferred region)

**Auto-populated by pipeline (don't add manually):**
- `EC2_SSH_PRIVATE_KEY`
- `EC2_HOST`

## Step 3: Set Up GitHub Actions Workflows

Ensure these workflow files exist in `.github/workflows/`:
- `infra-deploy.yml` - Infrastructure deployment
- `app-deploy.yml` - Application deployment

## Step 4: Deploy Infrastructure
```bash
# Make any change to infra/ folder to trigger deployment
cd infra
touch trigger-deploy.txt
git add .
git commit -m "Deploy infrastructure"
git push origin main
```

**Monitor**: Check GitHub Actions tab for infrastructure deployment progress.

## Step 5: Deploy Application
```bash
# Make any change to app/ folder to trigger deployment
cd app
touch trigger-deploy.txt
git add .
git commit -m "Deploy application"
git push origin main
```

**Monitor**: Check GitHub Actions tab for application deployment progress.

## Step 6: Test Deployment

### Get EC2 Instance IP
1. Go to AWS Console → EC2 → Instances
2. Find your instance and copy the public IP

### Test Application
```bash
# Health check
curl http://<EC2_PUBLIC_IP>:8080/health

# Main application
curl http://<EC2_PUBLIC_IP>:8080
```

### SSH Access (if needed)
```bash
# Get private key from GitHub Secrets and save to file
# Then connect:
ssh -i private_key.pem ubuntu@<EC2_PUBLIC_IP>
```

## Step 7: Verify Everything Works

✅ **Infrastructure deployed successfully**
- EC2 instance running
- Security groups configured
- ECR repository created

✅ **Application deployed successfully**
- Container running on port 8080
- Health endpoint responding
- Application accessible from internet

## Troubleshooting

### Common Issues:
1. **Bootstrap fails**: Check AWS credentials and permissions
2. **GitHub Actions fail**: Verify secrets are set correctly
3. **Application not accessible**: Check security group rules (port 8080)
4. **Container not starting**: Check application logs in GitHub Actions

### Debug Commands:
```bash
# Check container status on EC2
ssh ubuntu@<EC2_IP>
sudo docker ps
sudo docker logs <container_id>

# Check GitHub Actions logs
# Go to Actions tab in GitHub repository
```

## Cleanup (Optional)
```bash
# Destroy infrastructure
cd infra
terraform destroy

# Destroy bootstrap resources
cd ../bootstrap
terraform destroy
```
