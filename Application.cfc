component extends="framework.zero" {
  this.configFiles = this.root & "/config";
  this.defaultConfig.title = "Database Diagram";
  this.defaultConfig.outputImage = expandPath( "./output.gif" );
  this.defaultConfig.paths.model = expandPath( "model" );
  this.mappings["/model"] = this.defaultConfig.paths.model;

  public void function onRequestStart(string targetPage) {
    super.onRequestStart();

    var d = new diagram();
    d.setReload( structKeyExists( url, "reload" ) && isBoolean( url.reload ) && url.reload );

    request.output = local.d.get();
  }
}