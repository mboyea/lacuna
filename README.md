---
title: Lacuna CMS
author: [ Matthew T. C. Boyea ]
lang: en
subject: server
keywords: [ nix, docker, umami, server, cms, svelte, sveltekit, typescript, sass, website, fly, fly.io ]
default_: report
---
## A SvelteKit template with modern [CMS](https://en.wikipedia.org/wiki/Content_management_system) features, built using [FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software)

The goal is to *get out of the way of software engineers* and enable them to construct highly custom websites for their clients.

Lacuna provides a canvas upon which you can architect your own website.
[Find out why](#why-lacuna-instead-of-a-mainstream-cms).

### Installation

The purpose of Lacuna is for you to be able to completely change everything about it.
So the first step is to make your own copy!

- [Fork this repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo).
- [Clone *your forked repository*](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) from GitHub to your computer.

Because [Nix (the package manager)] manages all packages, it is the only dependency required to be installed manually.

- [Install Nix: the package manager](https://nixos.org/download/).
- [Enable Nix Flakes](https://nixos.wiki/wiki/Flakes).

From here, you can run any of the project [Scripts](#scripts).

However, you won't have access to the project packages (`npm`, `psql`, `podman`, `flyctl`, etc.) in your PATH by default.
You probably want those for testing and usage while debugging.
You can run `nix develop` to open a subshell with these dependencies.

This works fine, but it's nice to automatically have the software dependencies when you enter into the project directory.
To do that, we install [direnv](https://direnv.net/).

- [Install direnv](https://direnv.net/docs/installation.html).
- [Install nix-direnv](https://github.com/nix-community/nix-direnv#installation) for better caching (optional).
- Open a terminal in the project's root directory.
- Run `direnv allow`

Now you don't have to type `nix develop`; all the packages are automatically provided when your shell enters into the project directory.

### Usage

Be sure to [read the license](./LICENSE.md).

#### Scripts

Scripts can be run from within any of the project directories.

| Command | Description |
|:--- |:--- |
| `nix run` | Alias for `nix run .#start-dev all` |
| `nix run .#[SCRIPT] [TARGETS]` | Run a script |
| `nix develop` | Start a dev shell with project tools installed |

| SCRIPT | Description |
|:--- |:--- |
| `help` | Print this helpful information |
| `start-dev` | Start apps locally using devtools |
| `start-prod` | Start apps locally using their production images |
| `deploy` | Deploy app production images to Fly.io |

| TARGET | Description |
|:--- |:--- |
| `all` | Alias for `database analytics webserver` |
| `database` `postgres` | Script targets the database |
| `analytics` `umami` | Script targets the analytics server |
| `webserver` `sveltekit` | Script targets the webserver |

Lacuna scripts are declared in `flake.nix`, and defined in `scripts/`.

**Note:** Currently you cannot run scripts that use `podman` to create a container while offline. For more information, see [github.com/containers/podman/issues/23566](https://github.com/containers/podman/issues/23566).

#### Deployment (Fly.io)

You'll need to be signed into a [Fly.io] account to deploy.

- [Make a Fly.io account](https://fly.io/dashboard).
  Link your payment method in the account.
- Run `flyctl auth login`

Secret deployment credentials will be stored in the file `.env`.
The contents of this file can never be revealed publicly, so be careful to only share its contents with other developers.

- Create a file named `.env` in the root directory.
- Add to `.env`:

  ```sh
  FLY_APP_WEBSERVER="<unique_app_name>"
  FLY_APP_ANALYTICS="<unique_app_name>"
  FLY_APP_DATABASE="<unique_app_name>"
  POSTGRES_PASSWORD="<unique_password>"
  POSTGRES_WEBSERVER_PASSWORD="<unique_password>"
  POSTGRES_ANALYTICS_PASSWORD="<unique_password>"
  ```

- Run `nix run .#deploy all`

The application will perform its first deployment.
It may hang while deploying the webserver for the first time, but this is just a byproduct of waiting for Fly to initialize the application.
With patience, your server should deploy and you can visit the app online!

You can re-deploy after making changes to the database, server, or secrets with the same `.#deploy` command.

- `nix run .#deploy all`
- `nix run .#deploy secrets`
- `nix run .#deploy database webserver`

**If you ever modify the design of an existing database table, you must manually convert the old table before redeploying.**
It is recommended that you first test the conversion process on a fake database using `nix run .#start prod` and `psql -h localhost -U postgres`.

- Run `flyctl postgres connect --user postgres --password <unique_password>`
- Modify the old table using [ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html).

After initial deployment, you can use [flyctl](https://fly.io/docs/flyctl/) to manage your deployed servers.
Or visit [fly.io/dashboard](https://fly.io/dashboard).

### Features

Database by PostgreSQL.
Web Analytics by Umami.
Web Server by SvelteKit (Node).

#### Content Editor

TODO

#### Web Analytics

TODO

#### User Manager

TODO

<!--
#### Database Inspector

TODO

#### Page Search

TODO
-->

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
Umami (analytics), PostgreSQL (database), and Node (web server) are all commonly used and well-tested.

The Docker containers are designed to be as minimal as possible, containing only what is required to run each server.
This way the application has a very small attack surface.
Because each part of the app is in a separate Docker container, a breach of one doesn't compromise the entire application.

#### Performance

Lacuna is fast.

Your software is only as fast as its dependencies.
Node and PostgreSQL each have excellent community support for keeping them performant at scale.
Servers can be deployed by Fly anywhere in the world to minimize latency.
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

Scripts (defined in `scripts/`) are used to test and deploy the software.
`flake.nix` exposes the scripts to `nix run`, wrapping them with their required dependencies.
Each module in `modules/` is declared by `default.nix` and defined in `packages/`.

Source code for the web server is in `modules/sveltekit/`.
[SvelteKit] is used to build a [Node.js] server, making use of [Sass] for superior CSS features and [TypeScript] for type security in both the front-end and back-end of the server.
Nix packages a Docker image with this webserver inside.

Source code for the analytics server is in `modules/umami/`.
[Umami] is used to provide an analytics server that doesn't use cookies, respecting user privacy.

Source code for the database is in `modules/postgres/`.
[Postgres] is used to provide a SQL database that best supports concurrency at scale.

[Fly.io] is used as a hosting provider for the Postgres database and the server images.
Fly natively supports concurrent Postgres instances, and provides some [convenient CLI tools](https://fly.io/docs/flyctl/postgres/) for database management.
It also allows servers to connect to the database over an internal network, so the Postgres database doesn't have to be exposed to the internet.
These features make Fly an ideal hosting provider for performance and security.
If I ever decided that Fly was an inferior hosting option, it would be no problem to migrate from their service to another, because you can run Docker containers pretty much anywhere.
Hooray for avoiding [vendor lock-in](https://en.wikipedia.org/wiki/Vendor_lock-in)!

When this project is mature and commercially supported, complete documentation will be provided in `docs/`.
Until then, please first do your best to read the code and understand it, starting at the entrypoint of the program in `flake.nix`.
If you have any questions, please post a GitHub Issue.

### How to contribute?

This project doesn't support community contributions to the code right now.
You are free to post Issues in this repository, and if enough interest is generated, a process for community pull requests will be provided.

We are not currently receiving donations.
There is no way to fund the project at this time, but if enough interested is generated, a process for donations will be provided.

Feel free to fork, just be sure to [read the license](./LICENSE.md).

[Nix (the package manager)]: https://nixos.org/
[Docker]: https://docs.docker.com/get-started/overview/
[SvelteKit]: https://kit.svelte.dev/docs/introduction
[Node.js]: https://nodejs.org/en/docs/guides/getting-started-guide
[Angular]: https://angularjs.org/
[Sass]: https://sass-lang.com/guide
[Typescript]: https://www.typescriptlang.org/why-create-typescript
[Postgres]: https://www.postgresql.org/
[Fly.io]: https://fly.io/docs/
