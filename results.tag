<results>

  <ul id="results" if={opts.hits.length > 0}>
    <li each={opts.hits}>

      <h3><a href={url}>{title}</a></h3>

      <ul>
        <li each={hi in highlight.text} class="highlight">
          <raw-span content={hi}></raw-span>
        </li>
      </ul>

    </li>
  </ul>

  <p if={opts.hits.length == 0}>
    -- no results --
  </p>

</results>

<raw-span>
  <span></span>
  <script>this.root.innerHTML = opts.content</script>
</raw-span>
