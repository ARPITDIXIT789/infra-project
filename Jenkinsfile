pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Kya karna hai?')
  }

  environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
    ANSIBLE_FORCE_COLOR = 'true'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Lint') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        sh 'terraform -chdir=terraform fmt -check'
        sh 'cd ansible && ansible-lint . || true'
      }
    }

    stage('Terraform Init + Plan') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        sh 'terraform -chdir=terraform init -input=false'
        sh 'terraform -chdir=terraform plan -input=false -out=tfplan'
      }
    }

    stage('Approval') {
      when { expression { params.ACTION == 'apply' } }
      steps { input message: 'Plan dekh liya? Apply karein?' }
    }

    stage('Terraform Apply') {
      when { expression { params.ACTION == 'apply' } }
      steps { sh 'terraform -chdir=terraform apply -input=false tfplan' }
    }

    stage('Ansible Configure') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        withCredentials([
          sshUserPrivateKey(credentialsId: 'ansible-ssh-key', keyFileVariable: 'SSH_KEY'),
          file(credentialsId: 'vault-pass', variable: 'VAULT_FILE')
        ]) {
          sh '''
            cd ansible
            ansible-galaxy collection install -r requirements.yml
            ansible-playbook site.yml --syntax-check
            ansible-playbook site.yml \
              --private-key "$SSH_KEY" \
              --vault-password-file "$VAULT_FILE" \
              --diff
          '''
        }
      }
    }

    stage('Verify') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        sh '''
          terraform -chdir=terraform output -json public_ips | tr -d '[]"' | tr ',' '\n' | while read ip; do
            ip=$(echo $ip | xargs)
            [ -z "$ip" ] && continue
            echo "Checking $ip"
            curl -sf --max-time 10 http://$ip | grep -i "served by"
          done
        '''
      }
    }

    stage('Terraform Destroy') {
      when { expression { params.ACTION == 'destroy' } }
      steps {
        input message: 'Sach mein destroy karna hai?'
        sh 'terraform -chdir=terraform init -input=false'
        sh 'terraform -chdir=terraform destroy -auto-approve -input=false'
      }
    }
  }

  post {
    failure { echo 'Pipeline fail hui, console output dekho.' }
  }
}
