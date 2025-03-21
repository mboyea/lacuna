<script lang="ts">
  import './+layout.scss'
</script>

<header id="page-header">
  <hgroup>
    <h1>Pico CSS</h1>
    <p>A minimal HTML example.</p>
  </hgroup>
  <nav>
    <ul>
      <li>
        <details class="dropdown">
          <summary role="button" class="secondary">Theme</summary>
          <ul>
            <li><a href="#" data-theme-switcher="auto">Auto</a></li>
            <li><a href="#" data-theme-switcher="light">Light</a></li>
            <li><a href="#" data-theme-switcher="dark">Dark</a></li>
          </ul>
        </details>
      </li>
    </ul>
  </nav>
</header>
<main tabindex="-1" id="page-main">
  <slot />
</main>
<footer id="page-footer">
  <small
    >Built with <a href="https://picocss.com">Pico</a> •
    <a href="https://github.com/picocss/examples/blob/master/v2-html/index.html"
      >Source code</a
    ></small
  >
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
  }
</style>

