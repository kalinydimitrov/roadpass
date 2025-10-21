# Initialize a new Git repository
git init

# Add all existing files
git add .

# Commit your initial version
git commit -m "Initial commit"

# Create and switch to staging branch
git branch -M staging

# Add your GitHub remote
git remote add origin https://github.com/kalinydimitrov/roadpass.git

# Verify remote was added
git remote -v

# Push to GitHub (main branch)

git push -u origin staging

# Run Terraform from inside the environment folder:

cd environments/staging

terraform init

terraform plan

terraform apply

# checkov security scan:

In project root (/mnt/d/Projects/ThorIndustries/Roadpass) execute: 
```
checkov -d .
```