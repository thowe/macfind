# macfind
Web based tool to do MAC address organization lookups instead of using a remote
site.  You can easily run this locally.

This is a Mojolicious::Lite application...  You can run this like any other
such program.  See https://docs.mojolicious.org/Mojolicious/Guides/Tutorial

This uses public registry data which can be downloaded from the IEEE
here: https://regauth.standards.ieee.org/standards-ra-web/pub/view.html

The idea is that this is a pretty simple search operation on public data,
so going to a remote site to have it find it for you seems silly.

This tool also scratches an itch for me, because the data entered can be
pasted directly out of the MAC table of a switch without needing to pre-edit
it in any way before entering it.  This makes it a one second copy/paste
operation.

The MAC address itself can be delimited with ".", ":", and "-" characters, but
not with spaces.  This is tested with the following outputs:

 * Ubiquiti Edge Switch "show mac-addr-table" output
 * Juniper switch "show ethernet-switching table"
 * Adtran TA5000 "show mac address-table"
 * probably works with many others
