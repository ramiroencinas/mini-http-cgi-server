=begin pod
=head1 perl6-mini-http-cgi server

Mini HTTP & CGI Server
Author: Ramiro Encinas Alarza - ramiro.encinas@gmail.com - Apr 2017

=end pod

use lib 'lib';
use Configuration;
use Response;

# check default-public-file
if !($public-dir ~ "/" ~ $default-public-file).IO.e { die "Default public file not found."; }

# concurrent loop for listen, incoming processing and response
react {
  say $listening-message;
  whenever IO::Socket::Async.listen($listen-server-host,$listen-port) -> $conn {
    # tapping incoming requests in binary format (blob)
    whenever $conn.Supply(:bin) -> $buf {
      my $response = response $buf;
      say "*Response data:*\n" ~ $response;
      $conn.write: $response.encode('UTF-8'); # .encode returns binary format (blob)
      $conn.close;
    }
  }
}
