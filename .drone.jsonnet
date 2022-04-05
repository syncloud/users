local name = "users";
local user = "tu";
local build(arch, test_ui) = {
    kind: "pipeline",
    name: arch,

    platform: {
        os: "linux",
        arch: arch
    },
    steps: [
        {
            name: "version",
            image: "debian:buster-slim",
            commands: [
                "echo $DRONE_BUILD_NUMBER > version",
                "echo " + arch + "$DRONE_BRANCH > domain"
            ]
        },
    {
        name: "download",
        image: "debian:buster-slim",
        commands: [
            "./download.sh "
        ]
    },
       {
        name: "package python",
        image: "debian:buster-slim",
        commands: [
            "./python/build.sh"
        ],
        volumes: [
            {
                name: "docker",
                path: "/usr/bin/docker"
            },
            {
                name: "docker.sock",
                path: "/var/run/docker.sock"
            }
        ]
    },
        {
            name: "build php",
            image: "debian:buster-slim",
            commands: [
                "./php/build.sh"
            ],
            volumes: [
                {
                    name: "docker",
                    path: "/usr/bin/docker"
                },
                {
                    name: "docker.sock",
                    path: "/var/run/docker.sock"
                }
            ]
        },

        {
            name: "build",
            image: "debian:buster-slim",
            commands: [
                "VERSION=$(cat version)",
                "./build.sh " + name + " $VERSION"
            ]
        },
        {
            name: "test-intergation",
            image: "syncloud/build-deps-" + arch,
            commands: [
              "pip2 install -r dev_requirements.txt",
              "APP_ARCHIVE_PATH=$(realpath $(cat package.name))",
              "DOMAIN=$(cat domain)",
              "cd integration",
              "py.test -x -s verify.py --domain=$DOMAIN --app-archive-path=$APP_ARCHIVE_PATH --device-host=device --app=" + name + " --device-user=" + user
            ]
        }] +
        (if test_ui then 
        [{
            name: "test-ui-desktop",
            image: "syncloud/build-deps-" + arch,
            commands: [
              "pip2 install -r dev_requirements.txt",
              "DOMAIN=$(cat domain)",
              "cd integration",
              "py.test -x -s test-ui.py --ui-mode=desktop --domain=$DOMAIN --device-host=device --app=" + name+ " --device-user=" + user,
            ],
            volumes: [{
                name: "shm",
                path: "/dev/shm"
            }]
        },
        {
            name: "test-ui-mobile",
            image: "syncloud/build-deps-" + arch,
            commands: [
              "pip2 install -r dev_requirements.txt",
              "DOMAIN=$(cat domain)",
              "cd integration",
              "py.test -x -s test-ui.py --ui-mode=mobile --domain=$DOMAIN --device-host=device --app=" + name+ " --device-user=" + user,
            ],
            volumes: [{
                name: "shm",
                path: "/dev/shm"
            }]
        }] else []) + [
        {
            name: "upload",
            image: "syncloud/build-deps-" + arch,
            environment: {
                AWS_ACCESS_KEY_ID: {
                    from_secret: "AWS_ACCESS_KEY_ID"
                },
                AWS_SECRET_ACCESS_KEY: {
                    from_secret: "AWS_SECRET_ACCESS_KEY"
                }
            },
            commands: [
              "VERSION=$(cat version)",
              "PACKAGE=$(cat package.name)",
              "pip2 install -r dev_requirements.txt",
              "syncloud-upload.sh " + name + " $DRONE_BRANCH $VERSION $PACKAGE"
            ]
        },
        {
            name: "artifact",
            image: "appleboy/drone-scp",
            settings: {
                host: {
                    from_secret: "artifact_host"
                },
                username: "artifact",
                key: {
                    from_secret: "artifact_key"
                },
                timeout: "2m",
                command_timeout: "2m",
                target: "/home/artifact/repo/" + name + "/${DRONE_BUILD_NUMBER}-" + arch,
                source: "artifact/*",
		             strip_components: 1
            },
            when: {
              status: [ "failure", "success" ]
            }
        }
    ],
    services: [
        {
            name: "device",
            image: "syncloud/systemd-" + arch,
            privileged: true,
            volumes: [
                {
                    name: "dbus",
                    path: "/var/run/dbus"
                },
                {
                    name: "dev",
                    path: "/dev"
                }
            ]
        },
        if arch == "arm" then {} else {
            name: "selenium",
            image: "selenium/standalone-firefox:4.0.0-beta-1-20210215",
            volumes: [{
                name: "shm",
                path: "/dev/shm"
            }]
        }
    ],
    volumes: [
        {
            name: "dbus",
            host: {
                path: "/var/run/dbus"
            }
        },
        {
            name: "dev",
            host: {
                path: "/dev"
            }
        },
        {
            name: "shm",
            temp: {}
        },
{
            name: "docker",
            host: {
                path: "/usr/bin/docker"
            }
        },
        {
            name: "docker.sock",
            host: {
                path: "/var/run/docker.sock"
            }
        }

    ]
};

[
    build("amd64", true),
    build("arm64", false),
    build("arm", false)
]
