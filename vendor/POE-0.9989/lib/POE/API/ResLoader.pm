package POE::API::ResLoader;

use vars qw($VERSION);
$VERSION = do {my($r)=(q$Revision: 1903 $=~/(\d+)/);sprintf"1.%04d",$r};

sub import {
    my $package = (caller())[0];
    my $self = shift;
    if(@_) {
        my $initializer = shift;
        if(ref $initializer eq 'CODE') {
            $initializer->();
        }
    }
}

=head1 NAME

POE::API::ResLoader - provides initialization interface for POE::Resources

=head1 SYNOPSIS

    use POE::API::ResLoader \&initialize;

    sub initialize {
        # do stuff here ...
    }

=head1 DESCRIPTION

POE::Resource modules needed a uniform standard way of doing stuff
whenever they are loaded. This module provides that interface.

On C<use>, this module will run the subroutine reference passed in to it. This
subroutine can do anything it deems necessary.

=head1 AUTHOR

Matt Cashner (eek+cpan@eekeek.org)

=head1 LICENSE

Copyright (c) 2003, Matt Cashner

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject
to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;
