<search>

  <results
    if={results}
    hits={results.hits}
    total={results.total}
    page={results.page}
    page_count={results.page_count}
    onselect={opts.onselect}
    prev_url={results.prev_url}
    next_url={results.next_url}
    ></results>

  <p if={searching}>searching ...</p>

  <p if={error} class="alert alert-danger">{error}</p>

  <script>

    function buildQuery(q) {
      return {
        query_string: {
          default_field: 'text',
          query: q,
          default_operator: 'AND',
        },
      }
    }

    function search(query, success, error) {
      $.ajax({
        url: '/search',
        method: 'POST',
        data: JSON.stringify({
          from: (query.page - 1) * query.size,
          size: query.size,
          query: buildQuery(query.q),
          collections: query.collections,
          fields: ['title', 'url'],
          highlight: {fields: {text: {fragment_size: 40, number_of_fragments: 3}}},
        }),
        success: success,
        error: error,
      })
    }

    performSearch() {
      if(this.query === opts.query) return
      this.query = opts.query

      this.searching = true
      search(this.query, function(resp) {
        this.searching = false
        var url = function(p) {
          var u = "?q=" + encodeURIComponent(this.query.q)
          if(p > 1) u += "&p=" + p
          return u
        }.bind(this)
        page_count = Math.ceil(resp.hits.total / this.query.size)
        var page = this.query.page
        var prev_url = page > 1 ? url(page - 1) : null
        var next_url = page < page_count ? url(page + 1) : null
        this.results = {
          hits: resp.hits.hits,
          total: resp.hits.total,
          page: page,
          page_count: page_count,
          prev_url: prev_url,
          next_url: next_url,
        }
        this.error = null
        this.update()
      }.bind(this), function(err) {
        console.log(err.responseText)
        this.searching = false
        this.results = null
        this.error = "Server error while searching"
        this.update()
      }.bind(this))
    }

    this.on('update', this.performSearch.bind(this))
    this.performSearch()

  </script>

</search>
