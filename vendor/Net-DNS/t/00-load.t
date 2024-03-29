# $Id: 00-load.t 604 2006-09-07 18:47:16Z olaf $ -*-perl-*-


use Test::More tests => 77;
use strict;

BEGIN { 
    use_ok('Net::DNS'); 
    use_ok('Net::DNS::Resolver::Recurse');
    use_ok('Net::DNS::Nameserver');
    use_ok('Net::DNS::Resolver::Cygwin');  
    # can't test windows, has registry stuff
}


sub is_rr_loaded {
	my ($rr) = @_;
	
	return $INC{"Net/DNS/RR/$rr.pm"} ? 1 : 0;
}

my %skip = map { $_ => 1 } qw(SIG NXT KEY DS NSEC RRSIG DNSKEY DLV NSEC3);

my @rrs = grep { !$skip{$_} } keys %Net::DNS::RR::RR;



#
# Make sure that we haven't loaded any of the RR classes yet.
#
foreach my $rr (@rrs) {
	ok(!is_rr_loaded($rr), "Net::DNS::RR::$rr is not loaded");
}

#
# Check that we can load all the RR modules.
#
foreach my $rr (@rrs) {
	my $class;
	eval { $class = Net::DNS::RR->_get_subclass($rr); };

	diag($@) if $@;

	ok(is_rr_loaded($rr), "$class loaded");
}

#
# Did we get things imported correctly?
#
{ 	
	no strict 'refs';
	foreach my $sym (@Net::DNS::EXPORT) {
		ok(defined &{$sym}, "$sym is imported");
	}
}
			
