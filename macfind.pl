#!/usr/bin/env perl
#
# Expects "MAC Address Block Large (MA-L)" csv file from
# https://regauth.standards.ieee.org/standards-ra-web/pub/view.html
#

use Mojolicious::Lite -signatures;
use Mojo::File 'curfile';
use Text::CSV qw( csv );

# The file from ieee
my $oui_file = curfile->sibling('oui.csv');
my $mac_hash = csv(in => "$oui_file", key => 'Assignment',
                                      value => 'Organization Name');

# process_search takes the text entered into the web form to be split into
# individual lines, extract anything that looks like a MAC address, find its
# first 6 digits, search the $mac_hash structure for each one, and push them
# into an array for display on the web tool page.
sub process_search ( $search_string ) {
  my @splitstring = split(/^/, $search_string);
  my @ret_list;
  for my $mac (map /([0-9a-fA-F\:\-\.]{12,17})/, @splitstring) {
    next unless my @chars = $mac =~ m/([0-9a-fA-F])/g;
    my $mac_string = substr( uc(join('', @chars)) , 0, 6 );
    push @ret_list, [ $mac, $mac_hash->{$mac_string} ];
  }
  return \@ret_list;
};

get '/' => sub($c) {
  $c->render(template => 'default');
};

post '/' => sub($c) {
  $c->stash('results' => process_search( $c->param('searchdata') ));
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

% if( my $results = stash('results') ) {
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
