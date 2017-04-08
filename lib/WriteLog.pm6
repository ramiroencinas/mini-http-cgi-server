unit module WriteLog;

# write live log to terminal
sub write-log ($method, $path, $get-params, $body) is export {
  say "\n*Request data:*";
  say "DateTime: " ~ DateTime.now;
  say "Method: $method";
  say "Path: $path";
  say "GET params: $get-params";
  if $method eq "POST" { say "POST body: $body"; }
  say "";
}
