#!/usr/bin/env perl

use strict;
use FindBin qw($Bin);
use lib "$Bin/../modules";
use Getopt::Long;
use Class::Inspector;

my $module;
my $url;
my $host = 'localhost'; 
my $port = '4444';
my $browser = '*googlechrome';
my @test;
my @skip;
my $verbose;
my $species;
my $timeout;
my $live;

GetOptions(
  'module=s'  => \$module,
  'url=s'     => \$url,
  'host=s'    => \$host,
  'port=s'    => \$port,
  'browser=s' => \$browser,
  'test=s'    => \@test,
  'skip=s'    => \@skip,
  'verbose'   => \$verbose,
  'species=s' => \$species,
  'timeout=s' => \$timeout,
  'live'      => \$live,
);

die "You must specify a test module, eg. --module Metazoa" unless $module;
die "You must specify a url to test against, eg. --url http://test.metazoa.ensembl.org" unless $url;

# hack: collect errors so that we can check for selenium failures
my @errors;
$SIG{'__DIE__'} = sub { push(@errors, $_[0]) };

# try to use the package
my $package = "EnsEMBL::Selenium::Test::$module";
eval("use $package");
die "can't use $package\n$@" if $@;

# look for test methods
no strict 'refs';
my @methods = sort grep { /^test_/ } @{Class::Inspector->methods($package, 'public')};
use strict 'refs';
die "Module has no test methods (test methods must be named 'test_*')" unless @methods;

# create test object
my $object = $package->new(
  url => $url,
  host => $host,
  port => $port,
  browser => $browser,
  conf => {
    timeout => $timeout, 
    species => $species,
    live => $live,
  },
  verbose => $verbose,
);

my $methods_called = 0;

# run tests
foreach my $method (@methods) {
  next if @test and !grep {$_ =~ /\*$/ ? $method =~ /^(test_)?$_/i : $method =~ /^(test_)?$_$/i} @test;
  next if @skip and grep {$_ =~ /\*$/ ? $method =~ /^(test_)?$_/i : $method =~ /^(test_)?$_$/i} @skip;
  print "\n****************************************\n";
  print " $method\n";
  print "****************************************\n";
  $object->$method;
  $methods_called++;
}

# check for problems
if ($methods_called) {
  print "\nAll tests passed OK\n" 
    unless ($verbose or grep {/^Error.*selenium/} @errors or $object->testmore_output =~ /not ok/m);
} else {
  print "No test methods to run\n";
}
  
