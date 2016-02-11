<searchpage>

  <form>

    <div class="row">

      <div class="col-sm-3">
        <h1>Hoover</h1>
      </div>

      <div class="col-sm-8">

        <div class="form-group">
          <input name="q" value={q} class="form-control"
            placeholder="query ...">
        </div>

        <div class="form-inline">

          <div class="form-group">
            <label for="search-size">Results per page</label>
            <select class="form-control" id="search-size" name="size">
              <option
                each={size in sizeOptions}
                selected={size==this.parent.size}
                >{size}</option>
            </select>
          </div>

          <button type="submit" class="btn btn-primary btn-sm">search</button>

          <p class="pull-sm-right">
            <a href="/batch.html">batch search</a>
          </p>

        </div>

      </div>

      <div class="col-sm-1">
      </div>

    </div>

    <div class="row">

      <div id="collections-box" class="col-sm-3">

        <p if={!collections}>loading collections ...</p>

        <div each={collections} class="checkbox">
          <label>
            <input type="checkbox" value="{name}"
              checked={selectedCollections.indexOf(name) > -1}
              onchange={onSelectCollection}>
            {title}
          </label>
        </div>

        <em if={!collections.length}>none available</em>

        <input id="collections-input" type="hidden">

      </div>

      <div class="col-sm-9">

        <search
          query={query}
          onselect={onselect.bind(this)}
          ></search>

        <div if={selected}>
          <p if={!preview}>loading ...</p>
          <div if={preview}>
            <preview doc={preview}></preview>
          </div>
        </div>

      </div>

    </div>

  </form>

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
    this.q = args.q ? ("" + args.q).replace(/\+/g, ' ') : ""

    this.sizeOptions = [10, 50, 200, 1000]
    this.size = args.size ? +args.size : 10

    getCollections(function(resp) {

      this.collections = resp
      if(args.collections) {
        var sel = ''+args.collections
        this.selectedCollections = sel ? sel.split('+') : []
      }
      else {
        this.selectedCollections = resp.map(function(c) { return c.name })
      }

      if(this.q) {
        this.query = {
          q: this.q,
          collections: this.selectedCollections,
          page: args.p ? +args.p : 1,
          size: this.size,
        }
      }

      this.update()
      saveCollections()

    }.bind(this))

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
</searchpage>
