@Library('terraformLibrary') _
inputParameters()
pipeline {
   agent any
   tools {
      terraform 'terraform1.0.9'
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
               checkoutGit()
            }
         }
      }
      stage('Create S3 bucket for backend') {
         when {
            equals expected: true, actual: params.s3Bucket
         }
         steps {
            createBackendBucket()
         }
      }
      stage('Plan') {
         when {
            not {
               equals expected: true, actual: params.destroy
            }
         }   
         steps {
            terraformPlan()
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
               terraformApproval()
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
            sh "terraform apply -input=false tfplan"
         }
      }
      stage('Output') {
         when {
            not {
               equals expected: true, actual: params.destroy
            }
         }           
         steps {
            sh "terraform output --json > Terraform_Output.json"
         }
      }             
      stage('Destroy') {
         when {
            equals expected: true, actual: params.destroy
         }        
         steps {
            sh "terraform destroy --auto-approve"
            sh "aws s3 rb s3://${bucketName} --force" 
         }
      }
   }
}
