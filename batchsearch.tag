<batchsearch>

  <div class="container">

    <form class="row">

      <div class="form col-sm-6">

        <div class="form-group">
          <textarea
            placeholder="search terms, one per line ..."
            class="form-control"
            name="terms"
            >{termsArg}</textarea>
        </div>

        <button type="submit" class="btn btn-primary">search</button>

      </div>

      <div id="collections-box" class="col-sm-6">

        <h2>Collections</h2>

        <p if={!collections}>loading collections ...</p>

        <div each={collections} class="checkbox">
          <label>
            <input type="checkbox" value="{slug}"
              checked={selectedCollections.indexOf(slug) > -1}
              onchange={onSelectCollection}>
            {title}
          </label>
        </div>

        <em if={!collections.length}>none available</em>

        <input id="collections-input" type="hidden">

      </div>

    </form>

    <div class="row">

      <div class="col-sm-4">
        <div each={query in queries}>
          <h3>{query.q}</h3>
          <search
            query={query}
            onselect={selectCallback(query)}
            ></search>
        </div>
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

    function getCollections(callback) {
      $.ajax({
        url: '/collections',
        success: callback,
      })
    }

    function saveCollections() {
      var checkboxes = $('#collections-box input[type=checkbox]')
      var collectionsInput = $('#collections-input')
      if(checkboxes.filter(':not(:checked)').length > 0) {

        var selected = ''+(
          checkboxes
          .filter(':checked')
          .get()
          .map(function(c) { return c.value })
          .join(' ')
        )
        collectionsInput.attr('name', 'collections').val(selected)

      }
      else {

        collectionsInput.attr('name', null).val('')

      }
    }

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


    function preview(id, q, callback) {
      $.ajax({
        url: '/search',
        method: 'POST',
        data: JSON.stringify({
          query: {ids: {values: [id]}},
          fields: ['title', 'url', 'collection'],
          highlight: {fields: {text: {
            number_of_fragments: 0,
            highlight_query: {
              query_string: {
                default_field: 'text',
                query: q,
              },
            }
          }}},
        }),
        success: callback,
      })
    }

    onSelectCollection(evt) {
      saveCollections()
    }

    var args = parseQuery(window.location.href)

    getCollections(function(resp) {

      this.collections = resp
      if(args.collections) {
        var sel = ''+args.collections
        this.selectedCollections = sel ? sel.split('+') : []
      }
      else {
        this.selectedCollections = resp.map(function(c) { return c.slug })
      }

      this.termsArg = args.terms ? "" + args.terms : ""
      if(this.termsArg) {
        this.queries = this.termsArg.split('\n')
          .map(function(line) { return line.trim() })
          .filter(function(line) { return !! line })
          .map(function(line) {
            return {
              q: line.trim(),
              collections: this.selectedCollections,
              page: 1,
              size: 5,
            }
          }.bind(this))
      }

      this.update()
      saveCollections()

    }.bind(this))

    onselect(id, query) {

      this.selected = id
      this.preview = null
      this.update()

      preview(id, query.q, function(resp) {
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

    selectCallback(query) {
      return function(id) {
        this.onselect(id, query)
      }.bind(this)
    }

  </script>
</batchsearch>
