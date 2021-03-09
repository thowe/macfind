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
open( my $dfh, "<", 'oui.csv') or die "Can't open oui.csv file for reading";
while( my $fields = $csv->getline( $dfh ) ) {
    $mac_hash->{$fields->[1]} = $fields->[2];
}
close($dfh);

sub process_search ( $search_string ) {
  my @splitstring = split(/^/, $search_string);
  my $return_list = [];
  for my $line (@splitstring) {
    $line =~ s/^\s+|\s+$//g;
    next if( not $line =~ /([0-9a-fA-F:\:\-\.]{12,17})/ );
    my $mac = $1;
    my @chars = $mac =~ m/([0-9a-fA-F])/g;
    my $mac_string = substr( uc(join('', @chars)) , 0, 6 );
    push @$return_list, [( $mac, $mac_hash->{$mac_string} )];
  }
  return $return_list;
};

any ['GET', 'POST' ] => '/' => sub($c) {

  if( uc($c->req->method) eq 'POST' ) {
    #$c->stash( 'results' => $c->param('searchdata') );
    $c->stash( 'results' => process_search( $c->param('searchdata') ) );
  }
  else {
    $c->stash( 'results' => '' );
  }

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
<form action="<%= $c->url_for('/') %>" method="POST">
  <div class="form" name="search-div" id="search-div">
    <div class="field">
      <label class="label">MAC Addresses</label>
      <div class="control">
        <textarea class="textarea" name="searchdata" id="searchdata"
                  style="width: 80%;
                  overflow-y: scroll;
                  height: 140px"></textarea>
      </div>
    </div>
    <div class="field">
      <div class="control">
        <button class="button is-link"
                id="searchbutton" name="searchbutton" value="Search"
                >Submit</button>
      </div>
    </div>
  </div>
</form>

% if( $results ) {
<div class="plaintext" id="searchresults" name="searchresults">
<p>
% foreach my $result (@$results) {
<%= @$result[0] %>: <%= @$result[1] %><br/>
% }
<p>
</div>
% }

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
<div id="footer">
<p>Free Hong Kong!</p>
</div>
</body>

</html>
