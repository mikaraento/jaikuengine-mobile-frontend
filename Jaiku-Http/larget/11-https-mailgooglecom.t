# Copyright (c) 2007-2009 Google Inc.
# Copyright (c) 2006-2007 Jaiku Ltd.
# Copyright (c) 2002-2006 Mika Raento and Renaud Petit
#
# This software is licensed at your choice under either 1 or 2 below.
#
# 1. Perl (Artistic) License
#
# This library is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# 2. Gnu General Public license 2.0
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#
# This file is part of the JaikuEngine mobile frontend.

# Author: mikie@google.com (Mika Raento)

use strict;
use Test::More tests => 2;

use Danga::Socket;
use Jaiku::Http::Async;
use HTTP::Request;

my $reply;
my $error;
my $done = 0;

my $request = HTTP::Request->new(GET => 'https://mail.google.com/');
my $http_cb = sub {
  ($reply, $error) = @_;
  $done = 1;
};
my $http = Jaiku::Http::Async->new(
  $request, $http_cb
);

Danga::Socket->SetPostLoopCallback(
    sub { return !$done; });

Danga::Socket->EventLoop();

ok($reply, "got reply " . ($reply && $reply->as_string()));
is($error, undef);
