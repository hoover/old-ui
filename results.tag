<results>

  <p if={opts.hits.length > 0}>
    <a class="btn btn-secondary-outline btn-sm" if={opts.prev_url} href={opts.prev_url}>&laquo;</a>
    {opts.total} hits
    (page {opts.page}/{opts.page_count})
    <a class="btn btn-secondary-outline btn-sm" if={opts.next_url} href={opts.next_url}>&raquo;</a>
  </p>

  <ul id="results" if={opts.hits.length > 0}>
    <li each={opts.hits} class="results-item">
      <a href={parent.viewUrl(this)} target="_blank">

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

  <script>

    function pdfViewer(url) {
      return '/pdfjs/web/viewer.html?file=' + encodeURIComponent(url)
    }

    viewUrl(item) {
      var url = item.fields.url[0]
      var mime_type = (item.fields.mime_type || [])[0]
      if(mime_type == 'application/pdf') return pdfViewer(url)
    }

  </script>

</results>
