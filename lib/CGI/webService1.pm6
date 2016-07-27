unit module CGI::webService1;

# returns the income data
sub webService-sub1 ( $get-params, $post-payload ) is export {
  if $get-params { return $get-params; }
  if $post-payload { return $post-payload; }
}
