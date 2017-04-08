unit module Response;

use Configuration;
use URI;
use URI::Escape;
use CGI::webService1;
use WriteLog;

sub response ($buf) is export {

  # validations
  # check http entity max size
  if $buf.elems > $max-size-bytes-http-entity {
    # too long, return 413 error
    return $http-header_413;
  }

  # processing received http headers
  my Int $i = 0;
  # iterate $buf increasing $i and matching \r\n\r\n via dec code
  until ($buf[$i] == 13) && ($buf[$i+1] == 10) && ($buf[$i+2] == 13) && ($buf[$i+3] == 10) { $i++; }
  # extract headers from 0 to $i and decoding to utf-8
  my $headers = $buf.subbuf(0, $i).decode('UTF-8');
  my $body = $buf.subbuf($i, $buf.elems).decode('UTF-8');

  # initialize method, uri and protocol info from headers
  my ($method, $uri-full, $protocol) = "";

  # assign http method, full uri and http protocol version
  if $headers ~~ m:g:i:s/(GET|POST) (\/.*?) (HTTP\/.*?)$nl/ {
    $method   = $/[0][0].Str;
    $uri-full = $/[0][1].Str;
    $protocol = $/[0][2].Str;
  } else {
      # incorrect headers, return 400 Bad Request
      return $http-header_400;
  }

  # extract uri path and GET params
  my URI $uri .= new($uri-full);
  my $path = uri-unescape($uri.path);
  my $get-params = uri-unescape($uri.query);

  # shows processed incoming data
  write-log $method, $path, $get-params, $body;

  # preparing response from given path
  given $path {
    # the path is back1, lets go CGI module!
    when $_ ~~ /\/back1/ {
      return $http-header_200 ~ webService-sub1 $get-params, $body;
    }

    # file in path not exists, returns 404 http code
    when !($public-dir ~ $_).IO.e {
      return $http-header_404;
    }

    # the path is the public root dir, returns default public file
    when $_ eq "\/" {
      return $http-header_200 ~ slurp $public-dir ~ "/" ~ $default-public-file;
    }

    # the path is another file, returns it!
    default {
      return $http-header_200 ~ slurp $public-dir ~ $path;
    }
  }
}
