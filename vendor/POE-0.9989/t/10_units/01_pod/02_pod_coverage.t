# $Id: 02_pod_coverage.t 2171 2007-01-18 19:51:37Z rcaputo $
# vim: filetype=perl

use Test::More;
eval "use Test::Pod::Coverage 1.08";
plan skip_all => "Test::Pod::Coverage 1.08 required for testing POD coverage" if $@;

# These are the default Pod::Coverage options.
my $default_opts = {
  also_private => [
    qr/^[A-Z0-9_]+$/,      # Constant subroutines.
  ],
};

# Special case modules. Only define modules here if you want to skip
# (0) or apply different Pod::Coverage options ({}).  These options
# clobber $default_opts above, so be sure to duplicate the default
# options you want to keep.

my %special = (
  'POE::Wheel::ReadLine' => {
    also_private => [
      qr/^[A-Z0-9_]+$/,            # Constants subs.
      qr/^rl_/,                    # Keystroke callbacks.
    ],
    coverage_class => 'Pod::Coverage::CountParents',
  },
);

# Get the list of modules
my @modules = all_modules();
plan tests => scalar @modules;

foreach my $module ( @modules ) {
  my $opts = $default_opts;

  # Modules that inherit documentation from their parents.
  if ( $module =~ /^POE::(Loop|Driver|Filter|Wheel|Queue)::/ ) {
    $opts = {
      %$default_opts,
      coverage_class => 'Pod::Coverage::CountParents',
    };
  }
  SKIP: {
    if ( exists $special{$module} ) {
      skip "$module", 1 unless $special{$module};
      $opts = $special{$module} if ref $special{$module} eq 'HASH';
    }

    # Skip modules that can't load for some reason.
    eval "require $module";
    skip "Not checking $module ...", 1 if $@;

    # Finally!
    pod_coverage_ok( $module, $opts );
  }
}
