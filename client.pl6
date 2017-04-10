my $dest-ip =  '0.0.0.0'; # change with real destination ip
my $dest-port = 3000;

my $num-requests = 250; # number of requests to send
my $interval = 0.01; # one centisecond between requests

my $start = now;

for 1..$num-requests {
  await IO::Socket::Async.connect($dest-ip, $dest-port).then( -> $p {
      if $p.status {
          given $p.result {
              .print("GET \/ HTTP\/1.1\r\nheader line 2\r\n\r\n");
              react {
                  whenever .Supply() -> $v {
                      $v.say;
                  }
              }
              .close;
          }
      }
  });

  say "Response count: " ~ $_;

  sleep $interval;
}

my $end = now;
say "\nElapsed seconds: " ~ $end - $start;
