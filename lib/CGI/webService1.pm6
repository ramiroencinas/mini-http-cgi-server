unit module CGI::webService1;

# returns the incoming data
sub webService-sub1 ( $get-params, $body ) is export {
  if $get-params { return $get-params; }
  if $body { return $body; }
}
