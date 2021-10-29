pipeline {
   agent any
   tools {
      terraform 'terraform1.0.9'
   }
   parameters {
      string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
      booleanParam(name: 's3Bucket', defaultValue: false, description: 'Create s3 bucket for backend?')
      booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
      booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')
   }
   environment {
      AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
      AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
      bucketName = 'demodars08'
      awsRegion = 'us-east-1'
      userCred = 'cloud_user'
   }
   stages {
      stage('checkout') {
         steps {
            script{
               dir(params.environment) {
                  git "https://github.com/Darrs08/terraform-sample.git"
               }
            }
         }
      }
      stage('Create S3 bucket for backend') {
         when {
            equals expected: true, actual: params.s3Bucket
         }
         steps {
            withAWS(region: "${awsRegion}", credentials: "${userCred}") {
            awsIdentity()
            sh "aws s3api create-bucket --bucket ${bucketName} --region us-east-1"
            }
         }
      }
      stage('Plan') {
         when {
            not {
               equals expected: true, actual: params.destroy
            }
         }   
         steps {
            sh "cd ${environment} && terraform init -migrate-state -input=false -backend-config="bucket=${bucketName}""
            sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'
            sh "cd ${environment} && terraform plan -input=false -out tfplan "
            sh "cd ${environment} && terraform show -no-color tfplan > tfplan.txt"
         }
      }
      stage('Approval') {
         when {
            not {
               equals expected: true, actual: params.autoApprove
            }
            not {
               equals expected: true, actual: params.destroy
            }
         }
         steps {
            script {
               def plan = readFile 'tfplan.txt'
               input message: "Do you want to apply the plan?",
               parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
            }
         }
      }
      stage('Apply') {
         when {
            not {
               equals expected: true, actual: params.destroy
            }
         }           
         steps {
            sh "cd ${environment} && terraform apply -input=false tfplan"
         }
      }
      stage('Output') {
         when {
            not {
               equals expected: true, actual: params.destroy
            }
         }           
         steps {
            sh "cd ${environment} && terraform output --json > Terraform_Output.json"
         }
      }             
      stage('Destroy') {
         when {
            equals expected: true, actual: params.destroy
         }        
         steps {
            sh "cd ${environment} && terraform destroy --auto-approve"
            sh "aws s3 rb s3://${bucketName} --force" 
         }
      }
   }
}
