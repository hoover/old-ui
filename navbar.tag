<navbar>

  <a href="https://github.com/mgax/hoover" class="btn btn-secondary">about</a>
  <a href="/terms.html" class="btn btn-secondary">terms</a>

  <span if={me.username} class="btn-group" role="group">
    <button id="loggedin-btngroup" type="button"
            class="btn btn-secondary dropdown-toggle"
            data-toggle="dropdown"
            aria-haspopup="true" aria-expanded="false">
      {me.username}
    </button>
    <div class="dropdown-menu" aria-labelledby="loggedin-btngroup">
      <a if={me.admin} class="dropdown-item"
         href={me.urls.admin}
         >admin</a>
      <a class="dropdown-item"
         href={me.urls.password_change}
         >change password</a>
      <a class="dropdown-item"
         href={me.urls.logout}
         >logout</a>
    </div>
  </span>


  <span if={!me.username}>
    <a href={me.urls.login} class="btn btn-primary-outline">login</a>
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
