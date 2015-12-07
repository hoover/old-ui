<search>

  <div class="container">

    <form class="form-inline">
      <div class="form-group">

        <input name="q" value={q} class="form-control"
          placeholder="query ...">

        <button type="submit" class="btn btn-primary">search</button>

      </div>
    </form>

    <div class="row">

      <div class="col-sm-4">
        <results
          if={results}
          hits={results.hits}
          total={results.total}
          page={results.page}
          page_count={results.page_count}
          onselect={onselect}
          prev_url={results.prev_url}
          next_url={results.next_url}
          ></results>
        <p if={searching}>searching ...</p>
      </div>

      <div class="col-sm-8">
        <div if={selected}>
          <p if={!preview}>loading ...</p>
          <div if={preview}>
            <preview doc={preview}></preview>
          </div>
        </div>
      </div>

    </div>

  </div>

  <script>

    function parseQuery(url) {
      var rv = {}
      if(url.indexOf('?') > -1) {
        url.match(/\?(.*)/)[1].split('&').forEach(function(pair) {
          var kv = pair.split('=').map(decodeURIComponent)
          var k = kv[0], v = kv[1]
          if(! rv[k]) { rv[k] = [] }
          rv[k].push(v)
        })
      }
      return rv
    }

    function query(q) {
      return {
        query_string: {
          default_field: 'text',
          query: q,
        },
      }
    }

    function search(q, page, size, callback) {
      $.ajax({
        url: '/search',
        method: 'POST',
        data: JSON.stringify({
          from: (page - 1) * size,
          size: size,
          query: query(q),
          fields: ['title', 'url'],
          highlight: {fields: {text: {fragment_size: 40, number_of_fragments: 3}}},
        }),
        success: callback,
      })
    }

    function preview(id, q, callback) {
      $.ajax({
        url: '/search',
        method: 'POST',
        data: JSON.stringify({
          query: {ids: {values: [id]}},
          fields: ['title', 'url', 'collection'],
          highlight: {fields: {text: {
            number_of_fragments: 0,
            highlight_query: query(q),
          }}},
        }),
        success: callback,
      })
    }

    var args = parseQuery(window.location.href)
    this.q = args.q ? "" + args.q : ""

    if(this.q) {

      this.searching = true
      this.update()

      page = args.p ? +args.p : 1
      size = 10
      search(this.q, page, size, function(resp) {
        this.searching = false
        var url = function(p) {
          var u = "?q=" + encodeURIComponent(this.q)
          if(p > 1) u += "&p=" + p
          return u
        }.bind(this)
        page_count = Math.ceil(resp.hits.total / size)
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
        this.update()
      }.bind(this))

    }

    onselect(id) {

      this.selected = id
      this.preview = null
      this.update()

      preview(id, this.q, function(resp) {
        var hit = resp.hits.hits[0]
        this.preview = {
          text: hit.highlight.text[0],
          title: ""+hit.fields.title,
          url: ""+hit.fields.url,
          collection: ""+hit.fields.collection,
        }
        this.update()
      }.bind(this))

    }

  </script>
</search>
