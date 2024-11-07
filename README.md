---
title: lacuna
author: [ Matthew T. C. Boyea ]
lang: en
subject: server
keywords: [ nix, docker, umami, keycloak, server, cms, svelte, sveltekit, typescript, sass, website, fly, fly.io ]
default_: report
---
## A SvelteKit template with [modern CMS](https://jamstack.org/headless-cms/) features, built with [FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software)

The goal is to *get out of the way of software engineers* and enable them to construct highly custom websites for their clients.

Lacuna provides [simplicity](#simplicity), [security](#security), [scalability](#scalability), and [freedom](#freedom).

### Scripts

To run a script, type the `Command` in a shell with [Nix](https://nixos.org/download/) installed and [Flakes](https://nixos.wiki/wiki/Flakes) enabled.

| Command | Description |
|:--- |:--- |
| `nix run` | `nix run .#dev` |
| `nix run .#dev` | run the website locally |

### Features

Database by PostgreSQL.
Authentication by Keycloak.
Web Analytics by Umami.
Web Server by SvelteKit.

#### Content Editor

TODO

#### Web Analytics

TODO

#### Database Inspector

TODO

#### User Manager

TODO

### Why Lacuna instead of a CMS?

#### Freedom

Lacuna is forever free to use, both privately and commercially.

Lacuna is designed to run anywhere.
Its parts are compiled to very minimal docker containers.
You can host the docker containers on one server, across multiple servers, or in a distributed cloud computing network.
You aren't locked in to using any vendor, and thus you can always change to a different server provider if something isn't working out.

This is a highly modular codebase.
You are free to add, remove, or replace any part of Lacuna, and the rest will function just the same.
You aren't locked in to using any dependency, and thus anything is possible.

#### Simplicity

For the developer, Lacuna provides complete control using well-known tools.

For the client, Lacuna provides an approachable user interface, with every function available from one context menu.

#### Security

The dependencies of Lacuna were carefully chosen to be sure they're robust, well-supported, and secure.
Umami (analytics), Keycloak (authentication), PostgreSQL (database), and Vite (web server) are all commonly used and well-tested.

The Docker containers are designed to be as minimal as possible, containing only what is required to run each server.
This way the application has a very small attack surface.
Because each part of the app is in a seperate Docker container, a breach of one doesn't compromise the entire application.

#### Scalability

Your software is only as scalable as its dependencies.
PostgreSQL, Node.js, and Keycloak each have excellent guides for scaling their servers, so Lacuna will scale as large as you could need.
If a dependency or hosting provider no longer meets your needs, it's easy to replace them with another since Lacuna is highly modular and designed to run anywhere.

With Lacuna, it *is* up to the programmer to choose the best direction for scaling the software.
This *would* require expertise with the associated tools.

### How to contribute?

This project doesn't support community contributions to the code base right now.
You are free to post Issues in this repository, and if enough interest is generated, a process for pull requests will be provided.

We are not currently receiving donations.
There is no way to fund the project at this time, but if enough interested is generated, a process for donations will be provided.

Feel free to fork, just be sure to [read the license](./LICENSE.md).

