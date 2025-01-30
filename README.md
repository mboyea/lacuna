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

Because Nix manages all packages, it is the only dependency required to be installed manually.

- [Install Nix](https://nixos.org/download/).
- [Enable Flakes](https://nixos.wiki/wiki/Flakes).

Now you're ready to run the project scripts!

### Scripts

Scripts can be run from within any of the project directories.

Use `nix run .#[SCRIPT] help` for more information about a script.

| Command | Description |
|:--- |:--- |
| `nix run` | Alias for `nix run .#start dev` |
| `nix run .#help` | Print this helpful information |
| `nix run .#start` | Start the app locally |
| `nix run .#deploy` | Deploy the app |

Lacuna scripts are declared in `flake.nix`, and defined in `scripts/`.

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

## FAQ

### Why Lacuna instead of a mainstream CMS?

#### Freedom

Lacuna is forever free to use, both privately and commercially.

It's designed to run anywhere.
Each part is compiled to a small Docker container.
You can host the Docker containers on one server, across multiple servers, or in a distributed cloud computing network.
You aren't locked in to using any vendor, and thus you can always change to a different server provider if something isn't working out.

This is a modular codebase that focuses on extensibility.
You are free to add, remove, replace, or modify any part of Lacuna; the rest will function just the same.
Because you aren't locked in to using any dependency, anything is possible.

#### Simplicity

Lacuna is minimal and clear.

For the developer, Lacuna provides complete control using well-known tools.
Code-only solutions means no more complicated plugin systems with odd limitations and vulnerabilities.

For the client, Lacuna provides an approachable user interface by default, with every relevant function available from one context menu.
No clutter means no more confusing UI full of features your client doesn't need.

#### Security

Lacuna is designed for security.

The dependencies of Lacuna were carefully chosen to be sure they're robust, well-supported, and secure.
Umami (analytics), Keycloak (authentication), PostgreSQL (database), and Node (web server) are all commonly used and well-tested.

The Docker containers are designed to be as minimal as possible, containing only what is required to run each server.
This way the application has a very small attack surface.
Because each part of the app is in a separate Docker container, a breach of one doesn't compromise the entire application.

#### Performance

Lacuna is fast.

Your software is only as fast as its dependencies.
Node, PostgreSQL, and Keycloak each have excellent community support for keeping them performant at scale.
Servers can be deployed anywhere in the world to minimize latency.
If a dependency or hosting provider no longer meets your needs, it's easy to replace them with another.

You shouldn't have to wait long for software to rebuild during development.
Nix employs incremental builds, so when you change a part of your software it only rebuilds that part (derivation) that you're using and changing.
Further, hot-module replacement is employed where possible to prevent the need to rebuild while modifying some modules like the SvelteKit webserver.
Altogether, this significantly speeds up the feedback loop between development and testing.

### How does it work?

[Nix (the package manager)](https://nixos.org/) uses [declarative scripting](https://en.wikipedia.org/wiki/Declarative_programming) to:

- Install and lock dependencies.
- Create reproducible development environments.
- Compile apps into production-ready build packages.
- Containerize packages into Docker images.
- Deploy docker images to a target hosting provider.

Lacuna scripts are declared as a function of submodules in `flake.nix`.
Each script function is defined within the `scripts/` directory, and each submodule is defined by `default.nix` in its own subdirectory.

When this project is more mature and commercially supported, complete documentation will be provided in `docs/`.
Until then, please first do your best to read the code and understand it, starting at the entrypoint of the program in `flake.nix`.
If you have any questions, please post a GitHub Issue.

### How to contribute?

This project doesn't support community contributions to the code base right now.
You are free to post Issues in this repository, and if enough interest is generated, a process for community pull requests will be provided.

We are not currently receiving donations.
There is no way to fund the project at this time, but if enough interested is generated, a process for donations will be provided.

Feel free to fork, just be sure to [read the license](./LICENSE.md).
