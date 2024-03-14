pipeline {
  agent any
  // Global Tool Configuration 에서 설정한 Name
  tools {
    maven 'Maven3' 
  }
 
  // 해당 스크립트 내에서 사용할 로컬 변수들 설정
  // 레포지토리가 없으면 생성됨
  // Credential들에는 젠킨스 크레덴셜에서 설정한 ID를 사용
  environment {
    dockerHubRegistry = 'sooyounkim/jenkins' 
    dockerHubRegistryCredential = 'docker_hub' 
    githubCredential = 'git_hub'
    gitEmail = 'jwk231106@gmail.com'
    gitName = 'jiwoo231106'
  }
 
  stages {
 
    // 깃허브 계정으로 레포지토리를 클론한다.
    stage('Checkout Application Git Branch') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: githubCredential, url: 'https://github.com/jiwoo231106/kg_project3.git']]])
      }
      // steps 가 끝날 경우 실행한다.
      // steps 가 실패할 경우에는 failure 를 실행하고 성공할 경우에는 success 를 실행한다.
      post {
        failure {
          echo 'Repository clone failure' 
        }
        success {
          echo 'Repository clone success' 
        }
      }
    }
 
    // Maven 을 사용하여 Jar 파일 생성    
    stage('Maven Jar Build') {
      steps {
        sh 'mvn clean install'  
      }
      post {
        failure {
          echo 'Maven war build failure' 
        }
        success {
          echo 'Maven war build success'
        }
      }
    }
    stage('Docker Image Build') {
      steps {
        // 도커 이미지 빌드
        sh "docker build . -t ${dockerHubRegistry}:${currentBuild.number}"
      }
      // 성공, 실패 시 슬랙에 알람오도록 설정
      post {
        failure {
          echo 'Docker image build failure'
          slackSend (color: '#FF0000', message: "FAILED: Docker Image Build '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        success {
          echo 'Docker image build success'
          slackSend (color: '#0AC9FF', message: "SUCCESS: Docker Image Build '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
      }
    }  
 
    stage('Docker Image Push') {
      steps {
        // 젠킨스에 등록한 계정으로 도커 허브에 이미지 푸시
        withDockerRegistry(credentialsId: docker_hub, url: '') {
          sh "docker push ${dockerHubRegistry}:${currentBuild.number}"
          // 10초 쉰 후에 다음 작업 이어나가도록 함
          sleep 10
        } 
      }
 
      post {
        failure {
          echo 'Docker Image Push failure'
          sh "docker rmi ${dockerHubRegistry}:${currentBuild.number}"
          slackSend (color: '#FF0000', message: "FAILED: Docker Image Push '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        success {
          echo 'Docker Image Push success'
          sh "docker rmi ${dockerHubRegistry}:${currentBuild.number}"
          slackSend (color: '#0AC9FF', message: "SUCCESS: Docker Image Push '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
      }
    }
 
    stage('K8S Manifest Update') {
      steps {
        // git 계정 로그인, 해당 레포지토리의 main 브랜치에서 클론
        git credentialsId: git_hub,
            url: 'https://github.com/jiwoo231106/kg_project3.git',
            branch: 'master'  
 
        // 이미지 태그 변경 후 메인 브랜치에 푸시
        sh "git config --global user.email ${gitEmail}"
        sh "git config --global user.name ${gitName}"
        sh "sed -i 's/jenkins:.*/jenkins:${currentBuild.number}/g' ./backwas.yaml"
        sh "git add ."
        sh "git commit -m 'fix:${dockerHubRegistry} ${currentBuild.number} image versioning'"
        sh "git branch -M master"
        sh "git remote remove origin"
        sh "git remote add origin git@github.com:jiwoo231106/kg_project3.git"
        sh "git push -u origin master"
      }
      post {
        failure {
          echo 'K8S Manifest Update failure'
          slackSend (color: '#FF0000', message: "FAILED: K8S Manifest Update '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        success {
          echo 'K8s Manifest Update success'
          slackSend (color: '#0AC9FF', message: "SUCCESS: K8S Manifest Update '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
      }
    }
 
  }
}
