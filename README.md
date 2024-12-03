---
title: Lacuna CMS
author: [ Matthew T. C. Boyea ]
lang: en
subject: server
keywords: [ nix, docker, umami, keycloak, server, cms, svelte, sveltekit, typescript, sass, website, fly, fly.io ]
default_: report
---
## A SvelteKit template with modern [CMS](https://en.wikipedia.org/wiki/Content_management_system) features, built using [FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software)

The goal is to *get out of the way of software engineers* and enable them to construct highly custom websites for their clients.

Lacuna provides a canvas upon which you can architect your own application.
[Find out why](#why-lacuna-instead-of-a-mainstream-cms).

### Get Started

The purpose of Lacuna is for you to be able to completely change everything about it.
So the first step is to make your own copy!

- [Fork this repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo).
- [Clone *your forked repository*](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) from GitHub to your computer.

Because Nix manages all dependencies, it is the only tool required to be installed manually.

- [Install Nix](https://nixos.org/download/).
- [Enable Flakes](https://nixos.wiki/wiki/Flakes).

Now you're ready to run the project scripts!

### Scripts

Lacuna scripts are declared in `flake.nix`.

| Command | Description |
|:--- |:--- |
| `nix run` | alias for `nix run .#start dev` |
| `nix run .#help` | print this helpful information |
| `nix run .#start` | start the app locally |
| `nix run .#deploy` | deploy the app |
| `nix run .#init` | initialize the app for deployment |

Use `nix run .#[SCRIPT] help` for more information about a script.
Use `nix run` as an alias for `nix run .#start dev`.

#### TODO `nix run .#init help`

```sh
Initialize the app for deployment.

Usage:
  nix run .#init [SCRIPT]

Scripts:
  help  --help  -h  Print this helpful information
  stage             Stand up all hosting providers for a staging deployment
  prod              Stand up all hosting providers for a production deployment
```

#### TODO `nix run .#deploy help`

```sh
Deploy the app.

Usage:
  nix run .#deploy [SCRIPT]

Scripts:
  help  --help  -h  Print this helpful information
  stage             Build the app, package it into Docker containers, then deploy the docker containers for staging
  prod              Build the app, package it into Docker containers, then deploy the docker containers for production
```

### Features

Database by PostgreSQL.
Authentication by Keycloak.
Web Analytics by Umami.
Web Server by SvelteKit (Node).

#### Content Editor

TODO

#### Web Analytics

TODO

#### User Manager

TODO

#### Database Inspector

TODO

## FAQ

### Why Lacuna instead of a mainstream CMS?

#### Freedom

Lacuna is forever free to use, both privately and commercially.

Lacuna is designed to run anywhere.
Its parts are compiled to small docker containers.
You can host the docker containers on one server, across multiple servers, or in a distributed cloud computing network.
You aren't locked in to using any vendor, and thus you can always change to a different server provider if something isn't working out.

This is a highly modular codebase.
You are free to add, remove, or replace any part of Lacuna, and the rest will function just the same.
You aren't locked in to using any dependency, and thus anything is possible.

#### Simplicity

For the developer, Lacuna provides complete control using well-known tools.
Code-only solutions means no more complicated plugin systems with odd limitations.

For the client, Lacuna provides an approachable user interface, with every relevant function available from one context menu.
No clutter means no more confusing UI full of features you don't need.

#### Security

The dependencies of Lacuna were carefully chosen to be sure they're robust, well-supported, and secure.
Umami (analytics), Keycloak (authentication), PostgreSQL (database), and Vite (web server) are all commonly used and well-tested.

The Docker containers are designed to be as minimal as possible, containing only what is required to run each server.
This way the application has a very small attack surface.
Because each part of the app is in a seperate Docker container, a breach of one doesn't compromise the entire application.

#### Performance

Your software is only as fast as its dependencies.
Node, PostgreSQL, and Keycloak each have excellent community support for keeping them performant at scale.
Servers can be deployed anywhere in the world to minimize latency.
If a dependency or hosting provider no longer meets your needs, it's easy to replace them with another.

### How does it work?

[Nix (the package manager)](https://nixos.org/) uses [declarative scripting](https://en.wikipedia.org/wiki/Declarative_programming) to:

- Install and lock dependencies.
- Create reproducible development environments.
- Compile apps into production-ready build packages.
- Containerize packages into Docker images.
- Deploy docker images to any target hosting provider.

Lacuna scripts are declared as a function of submodules in `flake.nix`.

When this project is more mature and commercially supported, documentation will be provided in `/docs`.
Until then, please first do your best to read the code and understand it, starting at the entrypoint of the program in `flake.nix`.
If you have any questions, feel free to post an Issue.

### How to contribute?

This project doesn't support community contributions to the code base right now.
You are free to post Issues in this repository, and if enough interest is generated, a process for pull requests will be provided.

We are not currently receiving donations.
There is no way to fund the project at this time, but if enough interested is generated, a process for donations will be provided.

Feel free to fork, just be sure to [read the license](./LICENSE.md).
