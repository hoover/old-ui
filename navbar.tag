<navbar>

  <span class="btn-group" role="group">
    <button id="loggedin-btngroup" type="button"
            class="btn btn-secondary dropdown-toggle"
            data-toggle="dropdown"
            aria-haspopup="true" aria-expanded="false">
      ☰
    </button>
    <div class="dropdown-menu dropdown-menu-right" aria-labelledby="loggedin-btngroup">
      <a class="dropdown-item"
         href="https://github.com/mgax/hoover"
         >about</a>
      <a class="dropdown-item"
         href="/terms.html"
         >terms</a>
      <a if={!me.username} class="dropdown-item"
         href={me.urls.login}
         >login</a>
      <a if={me.username} class="dropdown-item"
         href={me.urls.logout}
         >({me.username}) logout</a>
      <a if={me.username} class="dropdown-item"
         href={me.urls.password_change}
         >change password</a>
      <a if={me.admin} class="dropdown-item"
         href={me.urls.admin}
         >admin</a>
    </div>
  </span>

  <script>

    function whoami(callback) {
      $.ajax({
        url: '/whoami',
        success: callback,
      })
    }

    whoami(function(me) {
      this.me = me
      this.update()
    }.bind(this))

  </script>
</navbar>
