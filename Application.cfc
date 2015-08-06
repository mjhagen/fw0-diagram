component extends="framework.zero"
{
  this.root = getDirectoryFromPath( getBaseTemplatePath()) & "../..";
  this.configFiles = this.root & "/config";
  this.defaultConfig["title"] = "Database Diagram";
  this.defaultConfig["outputImage"] = expandPath( "./output.gif" );

  this.mappings["/model"] = "#this.root#/../../model";

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public Void function onRequest(){
    jl = new javaloader.javaloader( loadColdFusionClassPath = true, loadPaths = [
      "#variables.config.lmPath#/lib/oy-lm-1.4.jar",
      "#variables.config.lmPath#/bin/junit-3.8.1.jar"
    ] );

    var Configuration = jl.create( "org.hibernate.cfg.Configuration" );
    var HBMCtoGRAPH = jl.create( "com.oy.shared.lm.ext.HBMCtoGRAPH" );
    var TaskOptions = jl.create( "com.oy.shared.lm.ant.TaskOptions" );
    var GRAPHtoDOTtoGIF = jl.create( "com.oy.shared.lm.out.GRAPHtoDOTtoGIF" );

    var conf = Configuration.init();

    for( hbmxmlFile in directoryList( variables.config.modelPath, false, "path", "*.hbmxml" ))
    {
      conf.addXML( replace( fileRead( hbmxmlFile ), 'cfc:root.model.', '', 'all' ));
    }

    conf.buildMappings();

    var opt = TaskOptions.init();
    opt.caption = "Diagram of ORM";
    // opt.colors = "##FCE08B, black, blue";

    var graph = HBMCtoGRAPH.load( opt, conf );

    GRAPHtoDOTtoGIF.transform( graph, "output.dot", variables.config.outputImage, "#variables.config.lmPath#/bin/graphviz-2.4/bin/dot.exe" );

    writeToBrowser( fileReadBinary( variables.config.outputImage ), "gif" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private void function writeToBrowser( required binary compressedImage, string format = "jpg" ){
    var imageIO = createObject( "java", "javax.imageio.ImageIO" );
    var byteArrayInputStream = createObject( "java", "java.io.ByteArrayInputStream" ).init( compressedImage );

    finishedImage = imageIO.read( byteArrayInputStream );

    var response = getPageContext().getFusionContext().getResponse();
        response.setHeader( "Content-Type", "image/#format#" );

    var outputStream = response.getResponse().getOutputStream();

    imageIO.write( finishedImage, format, outputStream );
    abort;
  }
}