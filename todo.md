---
title: Lacuna Devlog
author: [ Matthew T. C. Boyea ]
lang: en
date: November, 2024
subject: project
keywords: [ lacuna, cms, project, docs, code, history, log ]
default_: report
---

## Goals

- +1.0.0 | Content Editor + Web Analytics + User Manager

## Milestones

- [ ] (C) Draft Github Actions build pipeline to deploy docs/ to GitHub pages
- [ ] (B) Connect domain name www.lacunawebworks.com
- [ ] (B) Draft script `nix run .#deploy`
- [ ] (B) Draft fly packages.deploy
- [ ] (B) Draft fly packages.init
- [ ] (B) Draft secrets handling
- [ ] (A) Draft umami packages
- [ ] (A) Draft keycloak packages
- [ ] (A) Draft sveltekit pages content editor
- [ ] (A) Draft sveltekit /api/v1/pages
- [ ] (A) Draft sveltekit PageRequests.ts (credit https://github.com/michael/editable-website)
- [ ] (A) Draft sveltekit psql
- [x] (A) 2024-12-16 Draft `TODO.md` for +1.0.0 @docs
- [x] (A) 2024-12-14 Draft `postgres/` packages.serverImage @code
- [x] (A) 2024-12-03 Draft script `nix run .#start container` @code
- [x] (A) 2024-12-03 Draft `sveltekit/` packages.serverImage @code
- [x] (A) 2024-12-02 Draft `sveltekit/` packages.server @code
- [x] (A) 2024-11-20 Draft script `nix run .#start dev` & `nix run .#start preview` @code
- [x] (A) 2024-11-18 Draft script `nix run .#help` @code @docs
- [x] (A) 2024-11-16 Draft initial Nix code @code
- [x] (A) 2024-11-16 Determine Nix project organization at https://discourse.nixos.org/t/my-subflake-does-not-build-properly-or-how-to-package-monorepo-submodules-using-nix/55941/9 @docs
- [x] (A) 2024-11-06 Draft `README.md` for +1.0.0 @docs
