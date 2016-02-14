<batchsearch>

  <form>

    <div class="row">

      <div class="col-sm-3">
        <h1>Hoover</h1>
      </div>

      <div class="col-sm-9">

        <div class="form-group">
          <textarea
            placeholder="search terms, one per line ..."
            class="form-control"
            name="terms"
            >{termsArg}</textarea>
        </div>

        <div class="form-inline">

          <div class="form-group">
            <label for="search-size">Results per term</label>
            <select class="form-control" id="search-size" name="size">
              <option
                each={size in sizeOptions}
                selected={size==this.parent.size}
                >{size}</option>
            </select>
          </div>

          <button type="submit" class="btn btn-primary btn-sm">search</button>

          <p class="pull-sm-right">
            <a href="/">simple search</a>
          </p>

        </div>

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
        <div each={query in queries}>

          <h3>{query.q}</h3>

          <search query={query}></search>

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


    onSelectCollection(evt) {
      saveCollections()
    }

    var args = parseQuery(window.location.href)

    this.sizeOptions = [5, 10, 20]
    this.size = args.size ? +args.size : 5

    getCollections(function(resp) {

      this.collections = resp
      if(args.collections) {
        var sel = ''+args.collections
        this.selectedCollections = sel ? sel.split('+') : []
      }
      else {
        this.selectedCollections = resp.map(function(c) { return c.name })
      }

      this.termsArg = args.terms ? ("" + args.terms).replace(/\+/g, ' ') : ""
      if(this.termsArg) {
        this.queries = this.termsArg.split('\n')
          .map(function(line) { return line.trim() })
          .filter(function(line) { return !! line })
          .map(function(line) {
            return {
              q: line.trim(),
              collections: this.selectedCollections,
              page: 1,
              size: this.size,
            }
          }.bind(this))
      }

      this.update()
      saveCollections()

    }.bind(this))

  </script>
</batchsearch>
