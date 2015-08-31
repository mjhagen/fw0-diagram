

$( function() {
  var $panzoom = $( '.panzoom' );
  var $img = $panzoom.find( 'img' );

  $img.load(function(){
    var $this = $( this );

    $panzoom.panzoom({
      minScale: .8,
      maxScale: 5
    });

    $( window ).on( 'resize', function() {
      $panzoom.panzoom( 'resetDimensions' );
    });

    $panzoom.parent().on( 'mousewheel.focal', function( e ) {
      e.preventDefault();

      var delta = e.delta || e.originalEvent.wheelDelta;
      var zoomOut = delta ? delta < 0 : e.originalEvent.deltaY > 0;

      $panzoom.panzoom( 'zoom', zoomOut, {
        increment: 0.25,
        animate: true,
        focal: e
      });

      $panzoom.panzoom( 'resetDimensions' );
    });
  });
});