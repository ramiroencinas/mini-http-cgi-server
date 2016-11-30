=begin pod
=head1 perl6-mini-http-cgi server

Mini HTTP & CGI Server
Author: Ramiro Encinas Alarza - ramiro.encinas@gmail.com - Nov 2016

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
my $http-header_400 = "HTTP/1.1 400 Bad Request" ~ $nl ~ "Content-Type: text/html;charset=utf-8" ~ $nel ~ "<h3>Bad Request</h3>";
my $http-header_404 = "HTTP/1.1 404 Not Found" ~ $nl ~ "Content-Type: text/html;charset=utf-8" ~ $nel ~ "<h3>Not Found</h3>";
my $http-header_413 = "HTTP/1.1 413 Request Entity Too Large" ~ $nl ~ "Content-Type: text/html;charset=utf-8" ~ $nel ~ "<h3>Request Entity Too Large</h3>";
my $max-size-bytes-http-entity = 104857600; # 100mb

# check default-public-file
if !($public-dir ~ "/" ~ $default-public-file).IO.e { die "Default public file not found."; }

# listen and connection loop
react {
  whenever IO::Socket::Async.listen($listen-server-host,$listen-port) -> $conn {
    whenever $conn.Supply(:bin) -> $buf {
      # sub process handle the incoming http client connection
      $conn.write: process $buf;
      $conn.close;
    }
  }
}

sub process ($buf) {

  # in client we trust! returns 200 OK http code by default
  my $response = $http-header_200;

  # check http entity max size
  if $buf.elems > $max-size-bytes-http-entity {
    # too long, return 413 error
    $response = $http-header_413;
    return $response;
  }

  # get http headers
  my Int $i = 0;
  # iterate $buf increasing $i and matching \r\n\r\n via dec code
  until ($buf[$i] == 13) && ($buf[$i+1] == 10) && ($buf[$i+2] == 13) && ($buf[$i+3] == 10) { $i++; }
  # extract headers from 0 to $i and decoding to utf-8
  my $headers = $buf.subbuf(0, $i).decode('UTF-8');
  my $body = $buf.subbuf($i, $buf.elems).decode('UTF-8');

  # getting common headers
  my ($method, $uri-full, $protocol) = "";

  # assign http method, full uri and http protocol version
  if $headers ~~ m:g:i:s/(GET|POST) (\/.*?) (HTTP\/.*?)$nl/ {
    $method   = $/[0][0].Str;
    $uri-full = $/[0][1].Str;
    $protocol = $/[0][2].Str;
  } else {
      # incorrect headers, return 400 Bad Request
      $response = $http-header_400;
      return $response;
  }

  # extract uri path and GET params
  my URI $uri .= new($uri-full);
  my $path = uri-unescape($uri.path);
  my $get-params = uri-unescape($uri.query);

  # shows processed incoming data
  write-log $method, $path, $get-params, $body;

  given $path {
    # the path is back1, lets go CGI module!
    when $_ ~~ /\/back1/ {
      $response ~= webService-sub1 $get-params, $body;
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
  return $response.encode('UTF-8');
}

# write live log to terminal
sub write-log ($method, $path, $get-params, $body) {
  say "DateTime: " ~ DateTime.now;
  say "Method: $method";
  say "Path: $path";
  say "GET params: $get-params";
  if $method eq "POST" { say "POST body: $body"; }
  say "-----------";
}
