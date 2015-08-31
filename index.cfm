<!DOCTYPE html>
<html>
  <head>
    <title>ORM Diagram</title>
    <style>
      html, body, .container, .panzoom{ height: 100%; width:100%; }
      html, body{ margin:0; padding:0; }
      .container{ overflow:hidden; }
      img{width:100%;height:100%;}
    </style>
  </head>
  <body>
    <div class="container">
      <div class="panzoom">
        <img src="diagram.cfc?method=get" />
      </div>
    </div>
    <script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="jquery.panzoom.min.js"></script>
    <script src="jquery.mousewheel.min.js"></script>
    <script src="diagram.js"></script>
  </body>
</html>