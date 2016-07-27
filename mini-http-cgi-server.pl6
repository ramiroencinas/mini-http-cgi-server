=begin pod
=head1 perl6-mini-http-cgi server

Mini HTTP & CGI Server
Author: Ramiro Encinas Alarza - ramiro.encinas@gmail.com - Ag 2016

=end pod
use URI;
use URI::Escape;
use lib 'lib';
use CGI::webService1;

# init vars
my $listen-server-host  = "localhost";
my $listen-port         = 3000;
my $default-public-file = "index.html";
my $public-dir = "./public";
my $nl = "\r\n";
my $nel = "\r\n\r\n";
my $http-header_200 = "HTTP/1.1 200 OK" ~ $nl ~ "Content-Type: text/html;charset=utf-8" ~ $nel;
my $http-header_404 = "HTTP/1.1 404 Not Found" ~ $nl ~ "Content-Type: text/html;charset=utf-8" ~ $nel ~ "<h3>Not Found</h3>";

# check default-public-file
if !($public-dir ~ "/" ~ $default-public-file).IO.e { die "Default public file not found."; }

# listen and connection loop
react {
  whenever IO::Socket::Async.listen($listen-server-host,$listen-port) -> $conn {
    whenever $conn.Supply -> $buf {
      # sub process handle the incoming http client connection
      $conn.print: process $buf;
      $conn.close;
    }
  }
}

sub process ($buf) {
  # split http headers and post payload
  my ($headers, $post-payload) = $buf.split($nel);

  my ($method, $uri-full, $protocol) = "";
  # assign http method, full uri and http protocol version
  if $headers ~~ m:g:i:s/(GET|POST) (\/.*?) (HTTP\/.*?)$nl/ {
    $method   = $/[0][0].Str;
    $uri-full = $/[0][1].Str;
    $protocol = $/[0][2].Str;
  }

  # extract uri path and GET params
  my URI $uri .= new($uri-full);
  my $path = uri-unescape($uri.path);
  my $get-params = uri-unescape($uri.query);

  # shows processed incoming data
  write-log $method, $path, $get-params, $post-payload;

  # returns 200 OK http code by default
  my $response = $http-header_200;
  given $path {
    # the path is back1, lets go CGI module!
    when $_ ~~ /\/back1/ {
      $response ~= webService-sub1 $get-params, $post-payload;
    }
    # file in path not exists, returns 404 http code
    when !($public-dir ~ $_).IO.e {
      $response = $http-header_404;
    }
    # the path is root, returns default public file
    when $_ eq "\/" {
      $response ~= slurp $public-dir ~ "/" ~ $default-public-file;
    }
    # the path is another file, returns it!
    default {
      $response ~= slurp $public-dir ~ $path;
    }
  }

  return $response;
}

# write live log to terminal
sub write-log ($method, $path, $get-params, $post-payload) {
  say "DateTime: " ~ DateTime.now;
  say "Method: $method";
  say "Path: $path";
  say "GET params: $get-params";
  if $method eq "POST" { say "POST payload: $post-payload"; }
  say "-----------";
}
