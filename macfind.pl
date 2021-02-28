#!/usr/bin/env perl
#
# Expects "MAC Address Block Large (MA-L)" csv file from
# https://regauth.standards.ieee.org/standards-ra-web/pub/view.html
#

use Mojolicious::Lite -signatures;
use Text::CSV;

my $csv = Text::CSV->new ({
  binary    => 1,
  auto_diag => 1,
});

my $mac_hash = {};
open( my $dfh, "<", 'oui.csv');
while( my $fields = $csv->getline( $dfh ) ) {
    $mac_hash->{$fields->[1]} = $fields->[2];
}
close($dfh);

get '/' => sub($c) {
  $c->stash( 'temp_text' => 'The Mac 50579C belongs to ' .
                      $mac_hash->{'50579C'} );
  $c->render(template => 'default');
};



app->start;

__DATA__

@@ default.html.ep
% title 'MAC Organization search';
% layout 'default';
% stash description => 'This is a MAC address lookup tool without the BS.';

<div class="form" name="search-div" id="search-div"
     style="width: 50%">
<form action="" method="post">
  <div class="form" name="search-div" id="search-div">
    <div class="field">
      <label class="label">MAC Addresses</label>
      <div class="control">
        <textarea class="textarea"
                  style="width: 80%;
                  overflow-y: scroll;
                  height: 140px"></textarea>
      </div>
    </div>
  </div>
</form>

<p><%= $temp_text %><p>

@@ layouts/default.html.ep
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title><%= title %></title>
  <meta name="description" content="<%= $description %>">
</head>

<body>
<%= content %>
</body>

</html>
