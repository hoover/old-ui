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
        <results if={hits} hits={hits} onselect={onselect}></results>
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

    function search(q, callback) {
      $.ajax({
        url: '/search',
        method: 'POST',
        data: JSON.stringify({
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
