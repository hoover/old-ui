<raw-span>

  <span></span>

  <script>

    this.root.innerHTML = opts.content

    this.on('updated', function() {
      this.root.innerHTML = opts.content
    }.bind(this))

  </script>

</raw-span>
