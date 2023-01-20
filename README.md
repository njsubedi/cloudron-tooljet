## What

Run [Tooljet](https://www.tooljet.com/) on [Cloudron](https://cloudron.io)

## Why

Because, why not?

## Build and Install

- Install Cloudron CLI on your machine: `npm install -g cloudron-cli`.
- Log in to your Cloudron using cloudron cli: `cloudron login <my.yourdomain.tld>`.
- Install Docker, and make sure you can push to docker hub, or install the docker registry app in your own Cloudron.
- Build and publish the docker image: `cloudron build`.
- If you're using your own docker registry, name the image properly,
  like `docker.example-cloudron.tld/john_doe/cloudron-erpnext`.
- Log in to Docker Hub and mark the image as public, if necessary.
- Install the app `cloudron install -l <erp.yourdomain.tld>`
- Look at the logs to see if everything is going as planned.

## Install the latest pre-built package
- Install Cloudron CLI on your machine: `npm install -g cloudron-cli`.
- Log in to your Cloudron using cloudron cli: `cloudron login <my.yourdomain.tld>`.
- Install the app `cloudron install -l <tooljet.yourdomain.tld> --image njsubedi/cloudron-tooljet:latest`
- Look at the logs to see if everything is going as planned.

Refer to the [Cloudron Docs](https://docs.cloudron.io/packaging/cli) for more information.

## Logging in

After first-time setup, login with the default username `dev@tooljet.io` and default password `password`.

## LDAP Connection [WIP]

## Third-party Intellectual Properties

All third-party product names, company names, and their logos belong to their respective owners, and may be their
trademarks or registered trademarks.