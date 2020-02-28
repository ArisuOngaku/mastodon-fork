def genEnv() {
  return genEnv('27')
}

def genEnv(rubyVersion) {
  return [
   "BUNDLE_APP_CONFIG=./.bundle/",
   "DB_HOST=postgres-${rubyVersion}",
   "DB_USER=postgres",
   "REDIS_HOST=redis-${rubyVersion}",
   "RAILS_ENV=test",
   "PARALLEL_TEST_PROCESSORS=4",
   "ALLOW_NOPAM=true",
   "CONTINUOUS_INTEGRATION=true",
   "DISABLE_SIMPLECOV=true",
   "PAM_ENABLED=false", // Todo: enable this
   "PAM_DEFAULT_SERVICE=pam_test",
   "PAM_CONTROLLED_SERVICE=pam_test_controlled",
   "GEM_HOME=$WORKSPACE/vendor/bundle",
   "HOME=$WORKSPACE"
  ]
}

def withDockerNetwork(Closure inner) {
  def networkId
  try {
    networkId = UUID.randomUUID().toString()
    sh "docker network create ${networkId}"
    inner.call(networkId)
  } finally {
    try {
      sh "docker network rm ${networkId}"
    } catch (err) {
      echo err
    }
  }
}


def install() {
  stage('install') {
    sh 'yarn install --frozen-lockfile'
    stash name: "${env.BUILD_ID}-node", includes: "**"
  }
}

def testWebui() {
  stage('Test webui') {
    unstash "${env.BUILD_ID}-node"
    sh './bin/retry yarn test:jest'
  }
}

def installRubyDependencies(rubyVersion) {
  stage("Install ruby dependencies ruby ${rubyVersion}") {
    unstash "${env.BUILD_ID}-node"

    sh 'ruby --version'
    sh "ruby -e 'puts RUBY_VERSION' | tee /tmp/.ruby-version"
    sh '''
      bundle config set deployment 'true'
      bundle config set with 'pam_authentication'
      bundle config set without 'development production'
      bundle config set frozen 'true'
    '''
    sh 'bundle install --jobs 16 --retry 3'

    stash name: "${env.BUILD_ID}-ruby-${rubyVersion}", includes: "**"
  }
}

// Requires ffmpeg
def unitTests(rubyVersion) {
  stage("Unit tests ruby ${rubyVersion}") {
    unstash "${env.BUILD_ID}-ruby-${rubyVersion}"
    sh './bin/rails assets:precompile'
    sh './bin/rails parallel:create parallel:load_schema parallel:prepare'
    sh './bin/retry bundle exec parallel_test ./spec/ --group-by filesize --type rspec'
  }
}

def testMigrations(rubyVersion) {
  stage('Migrations') {
    unstash "${env.BUILD_ID}-ruby-${rubyVersion}"
    sh 'ruby --version'
    sh './bin/rails parallel:create'
    sh './bin/rails parallel:migrate'
  }
}

def testTranslations(rubyVersion) {
  stage('Translations') {
    unstash "${env.BUILD_ID}-ruby-${rubyVersion}"
    sh 'bundle exec i18n-tasks check-normalized'
    sh 'bundle exec i18n-tasks unused -l en'
    sh 'bundle exec i18n-tasks check-consistent-interpolations'
    sh 'bundle exec rake repo:check_locales_files'
  }
}


def installAndTestVersion(rubyVersion, dockerContainer, redisDocker, postgresDocker) {
  ws("${WORKSPACE}-ruby${rubyVersion}") {
    dir('vendor') {
      deleteDir()
    }
    dockerContainer.inside {
      withEnv(genEnv()) {
        installRubyDependencies(rubyVersion)
      }
    }
  }
  ws("${WORKSPACE}-unit_tests_${rubyVersion}") {
    dir('vendor') {
      deleteDir()
    }
    withDockerNetwork { n ->
      redisDocker.withRun("--network ${n} --name redis-${rubyVersion}") {
        postgresDocker.withRun("--network ${n} --name postgres-${rubyVersion}") {
          dockerContainer.inside("--network ${n}") {
            withEnv(genEnv(rubyVersion)) {
              unitTests(rubyVersion)
            }
          }
        }
      }
    }
  }
}


node {
  stage('git checkout') {
    dir('vendor') {
      deleteDir()
    }
    checkout scm
  }

  def ruby27Docker
  def ruby26Docker
  def ruby25Docker
  def nodeDocker
  def redisDocker
  def postgresDocker

  stage('Prepare docker images') {
    ruby27Docker = docker.build("toot-party-jenkins-ruby27:${env.BUILD_ID}", "-f jenkins/Ruby27.Dockerfile .")
    ruby26Docker = docker.build("toot-party-jenkins-ruby26:${env.BUILD_ID}", "-f jenkins/Ruby26.Dockerfile .")
    ruby25Docker = docker.build("toot-party-jenkins-ruby25:${env.BUILD_ID}", "-f jenkins/Ruby25.Dockerfile .")
    nodeDocker = docker.image("circleci/node:12-buster")
    redisDocker = docker.image("circleci/redis:5-alpine")
    postgresDocker = docker.image("circleci/postgres:10.6-alpine")
  }

  ruby27Docker.inside {
    withEnv(genEnv()) {
      install()
    }
  }

  parallel test_webui: {
    nodeDocker.inside {
      withEnv(genEnv()) {
        testWebui()
      }
    }
  }, ruby_27: {
    node {
      installAndTestVersion('27', ruby27Docker, redisDocker, postgresDocker)

      ws("${WORKSPACE}-migrations") {
        dir('vendor') {
          deleteDir()
        }
        withDockerNetwork { n ->
          redisDocker.withRun("--network ${n} --name redis-migrations") {
            postgresDocker.withRun("--network ${n} --name postgres-migrations") {
              ruby27Docker.inside("--network ${n}") {
                withEnv(genEnv('migrations')) {
                  testMigrations('27')
                }
              }
            }
          }
        }
      }

      ws("${WORKSPACE}-translations") {
        dir('vendor') {
          deleteDir()
        }
        ruby27Docker.inside {
          withEnv(genEnv()) {
            testTranslations('27')
          }
        }
      }
    }
  }, ruby_26: {
    node {
      installAndTestVersion('26', ruby26Docker, redisDocker, postgresDocker)
    }
  }, ruby_25: {
    node {
      installAndTestVersion('25', ruby25Docker, redisDocker, postgresDocker)
    }
  }
}
