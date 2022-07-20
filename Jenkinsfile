node {
    def app
    stage('clean workspace'){
        echo 'Clean Workspace '
        cleanWs()
    }
    stage('Clone repository') {
        echo "Cloning git repository to workspace"
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git_akash', url: 'https://github.com/akki8400/smallcase-task.git']]])
    }

    stage('Build image') {
        echo 'Build the docker flask image'
        app = docker.build("megiakki/versha-project")
    }

    stage('Test image') {
        echo 'Test the docker flask image'
        app.inside {
            sh 'python test.py'
        }
    }
    stage('Push image') {
        echo 'Push image to the docker hub'
        docker.withRegistry('https://registry.hub.docker.com', 'DOCKER_AKKI') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
    stage('Update the deployment file'){
    echo 'update the deployment files to re-apply it on deployment'

     sh "sed -i s/%IMAGE_NO%/${env.BUILD_NUMBER}/g flask-deployment.yaml"
     sh "cat flask-deployment.yaml"
    }
    stage('Deploy the flask app'){
      echo 'Deploy the flasj image at AWS EKS, on Cluster already present in EKS'
      withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'AWS_CREDS',
              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]){
      sh '''

              #export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/lib/jvm/java-11-openjdk-11.0.7.10-1.el8_1.x86_64/bin:/root/bin:/root/bin:/usr/local/bin/aws
              #aws configure list-profiles
              #curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/kubectl
              #chmod +x ./kubectl
              #mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
              kubectl version --short --client
              eksctl version
              aws eks --region us-west-2 update-kubeconfig --name versha-project
              kubectl get svc
              echo "Execute the deployment"
              #kubectl create namespace smallcase-demo
              if [ $? -eq 0 ]; then
                  echo "namespace smallcase-demo already exists"
                  kubectl get all -n smallcase-demo
              else
                  echo "create demo namespace"
                  kubectl create namespace smallcase-demo
              fi
              echo "Apply the deployment"
              kubectl apply -f flask-deployment.yaml
              echo "Create the flask service"
              kubectl apply -f flask-service.yaml
              sleep 5s
              echo "\n\n Deployment details \n\n"
              kubectl get all -n smallcase-demo

              echo "Deployment done successfully"
        '''
    }  }
    stage('Deployment Test'){
        echo 'Test the deployment using curl on service external address'
        withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'AWS_CREDS',
                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
            ]]){
        sh '''
                echo $PATH
                #export PATH=$PATH:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/lib/jvm/java-11-openjdk-11.0.7.10-1.el8_1.x86_64/bin:/root/bin:/root/bin:/usr/local/bin/aws:/var/lib/jenkins/bin
                kubectl get all -n smallcase-demo
                sleep 20s
                EXTERNAL_IP=`kubectl get service flask-service -n smallcase-demo | awk 'NR==2 {print $4}'`
                STATUS_CODE=`curl -s -o /dev/null -w "%{http_code}" http://${EXTERNAL_IP}:5000`
                echo $STATUS_CODE
                if [ $STATUS_CODE -eq 200 ]; then
                    echo "Deployment done successfully"
                else
                    echo "\n\nApplication not responding deployment Failed\n\n "
                    exit 1
                fi
          '''
        } }
        stage('Clean docker images from local') {
      sh '''
          sudo docker images -a | grep "versha-project" | awk '{print $3}' | xargs docker rmi -f
      '''

  }
}
