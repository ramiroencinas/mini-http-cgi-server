# mini-http-cgi-server
HTTP & CGI Server Proof of Concept

A basic HTTP & CGI implementation using Perl 6 and IO::Socket::Async to allow multithreading.

Currently only implements:

- 200, 400, 404 and 413 HTTP status response codes.
- GET and POST HTTP methods.
- Binary socket processing.
- Encoding to UTF-8 by default.
- Pseudo-CGI scripts via Perl6 Modules (lib/CGI).
- Live logs via stdout.

And doesn't implements:

- Cookies.
- File uploading.
- Client information beyond HTTP headers and POST payload.
- Security.

Required Perl6 modules:

- URI;
- URI::Escape;

Use:

- perl6 mini-http-cgi-server.pl6

- run web-client in http://localhost:3000

- enjoy CGI and AJAX!

NOTE: don't use in production environments!
