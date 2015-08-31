component {
  variables.jl = new javaloader.javaloader( loadColdFusionClassPath = true, loadPaths = [
    "#request.config.lmPath#/lib/oy-lm-1.4.jar"
  ] );

  public any function init() {
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  remote void function get( format = "svg" ) {
    var conf = jl.create( "org.hibernate.cfg.Configuration" ).init();
    for( var hbmxmlFile in directoryList( request.config.modelPath, true, "path", "*.hbmxml" )) {
      conf.addXML( reReplace( fileRead( hbmxmlFile ), 'cfc:[^"]+\.', '', 'all' ));
    }
    conf.buildMappings();

    var opt = jl.create( "com.oy.shared.lm.ant.TaskOptions" ).init();
    opt.caption = "Diagram of ORM";

    var graph = jl.create( "com.oy.shared.lm.ext.HBMCtoGRAPH" ).load( opt, conf );

    switch( format ) {
      case "gif" :
      case "jpg" :
        outputAsImage( graph, format );
        break;

      case "svg" :
        outputAsSVG( graph );
        break;
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private void function outputAsImage( required any graph, string format = "gif" ) {
    var response = getPageContext().getFusionContext().getResponse();
        response.setContentType( "image/#format#" );

    var outputStream = response.getOutputStream();

    var GRAPHtoDOTtoGIF = jl.create( "com.oy.shared.lm.out.GRAPHtoDOTtoGIF" );
        GRAPHtoDOTtoGIF.transform( graph, "output.dot", request.config.outputImage, "#request.config.lmPath#/bin/graphviz-2.4/bin/dot.exe" );

    var byteArrayInputStream = createObject( "java", "java.io.ByteArrayInputStream" ).init( fileReadBinary( request.config.outputImage ));

    var imageIO = createObject( "java", "javax.imageio.ImageIO" );
        imageIO.write( imageIO.read( byteArrayInputStream ), format, outputStream );

    removeFile( request.config.outputImage );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private void function outputAsSVG( required any graph ) {
    var context = getPageContext();
        // context.setFlushOutput( false );

    var response = context.getFusionContext().getResponse();
        // response.resetBuffer();
        // response.setContentType( "image/svg+xml" );

    var dotFile = replace( request.config.outputImage, '.', '-', 'all' ) & ".dot";
    var svgFile = replace( request.config.outputImage, '.', '-', 'all' ) & ".svg";
    var FileOutputStream = createObject( "java", "java.io.FileOutputStream" ).init( dotFile );

    var GRAPHtoDOT = jl.create( "com.oy.shared.lm.out.GRAPHtoDOT" );
        GRAPHtoDOT.transform( graph, FileOutputStream );

    lock scope="server" timeout="10" {
      cfexecute( name="#request.config.lmPath#/bin/graphviz-2.4/bin/dot.exe", arguments="-Tsvg #dotFile# -o #svgFile#" );
      removeFile( dotFile );
    }

    location( getFileFromPath( svgFile ));

    abort;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private void function removeFile( required string file ) {
    try {
      fileDelete( file );
    } catch( any e ) {

    }
  }
}