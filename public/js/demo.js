$(document).ready(function () {
  // click on Send GET button
  $("#btSendGET").click(function() {
    var inget = $("#iget").val();
    sendAjax(inget, "GET");
  });

  // click on Send POST button
  $("#btSendPOST").click(function() {
    var inpost = $("#ipost").val();
    sendAjax(inpost, "POST");
  });
});

function sendAjax (value, method) {
  // send GET or POST to back1 path (CGI module)
  $.ajax({
    type: method,
    url: "back1",
    data: value,
    success: function(data){write_return(data, method);},
    failure: function(err) {alert(err);}
  });
}

function write_return (data, method) {
  if ( method == "GET" ) { $("#get-returned").html(data); }
  if ( method == "POST" ) { $("#post-returned").html(data); }
}
