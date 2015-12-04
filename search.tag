<search>

  <div class="container">

    <form class="form-inline">
      <div class="form-group">

        <input name="q" value={q} class="form-control"
          placeholder="query ...">

        <button type="submit" class="btn btn-primary">search</button>

      </div>
    </form>

    <div>

      <results if={hits} hits={hits}></results>

      <p if={searching}>searching ...</p>

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

    function search(q, callback) {
      $.ajax({
        url: '/search',
        method: 'POST',
        data: JSON.stringify({
          query: {query_string: {default_field: 'text', query: q}},
          fields: ['title', 'url'],
          highlight: {fields: {text: {}}},
        }),
        success: callback,
      })
    }

    var qArg = parseQuery(window.location.href).q
    this.q = qArg ? ''+qArg : ''

    if(this.q) {

      this.searching = true
      this.update()

      search(this.q, function(resp) {
        this.searching = false
        this.hits = resp.hits.hits
        this.update()
      }.bind(this))

    }

  </script>
</search>