# action-gluon-build

GitHub Actions action to interact with the Gluon build-framework.

This Action utlizes the `gluon-build` docker container.


## Input

### container-version:
    description: 'Container version to use'
    default: 'master'

### gluon-path:
    description: 'Path to Gluon repository'
    required: true
### site-path:
    description: 'Path to Gluon site-directory'
    default: ''
### autoremove:
    description: 'Remove build-directories after build (Default: 1)'
    default: 1
### autoupdater-enabled:
    description: 'Autoupdater should be enabled by default (Default: 0)'
    default: 0
### autoupdater-branch:
    description: 'Default branch for the Autoupdater'
### broken:
    description: 'Determines if BROKEN devices should be built (Default: 0)'
    default: 0
### deprecated:
    description: 'Determines if deprecated devices should be built (Default: 0)'
    default: 0
### hardware-target:
    description: 'Target to build'
### make-target:
    description: 'Make target to use'
    default: ''
### priority:
    description: Priority indicator for the autoupdater
### release:
    description: 'Version string for the release to use'
