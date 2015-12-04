<results>

  <ul id="results" if={opts.hits.length > 0}>
    <li each={opts.hits} class="results-item">
      <a href="#">

        <h3>{fields.title}</h3>

        <ul class="results-highlight">
          <li each={hi in highlight.text}>
            <raw-span content={hi}></raw-span>
          </li>
        </ul>

      </a>
    </li>
  </ul>

  <p if={opts.hits.length == 0}>
    -- no results --
  </p>

</results>
