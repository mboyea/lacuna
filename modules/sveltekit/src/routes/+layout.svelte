<script lang="ts">
  import ThemeDropdown from '$lib/modules/ThemeDropdown.svelte';
  import './+layout.scss'
</script>

<header id="page-header">
  <hgroup>
    <h1>Lacuna</h1>
    <p>A SvelteKit template with sane defaults and CMS features.</p>
  </hgroup>
  <ThemeDropdown />
</header>
<main tabindex="-1" id="page-main">
  <slot />
</main>
<footer id="page-footer">
    <small>
      Built with
      <a href="https://github.com/mboyea/lacuna">Lacuna CMS</a>
    </small>
  <p>
    <small>
      <a href="https://nixos.org/">Nix</a>
      •
      <a href="https://nixos.org/">Postgres</a>
      •
      <a href="https://svelte.dev/">SvelteKit</a>
      •
      <a href="https://picocss.com">Pico Css</a>
      •
      <a href="https://fly.io/">Fly.io</a>
    </small>
  </p>
</footer>

<style lang="scss">
  :global(html, body) {
    height: max(100%, 100vh);
  }
  :global(body) {
    display: flex;
    flex-direction: column;
    margin: 0;
  }
  header {
    flex: 0 0;
    z-index: 1;
  }
  main {
    flex: 1 0;
    display: flex;
    flex-direction: column;
    &:focus {
      outline: none;
    }
  }
  footer {
    flex: 0 0;
    z-index: 1;
    text-align: center;
  }
</style>

