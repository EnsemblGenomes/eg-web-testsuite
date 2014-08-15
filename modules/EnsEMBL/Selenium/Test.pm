package EnsEMBL::Selenium::Test;

use strict;
use LWP::UserAgent;
use Time::HiRes;
use EnsEMBL::Selenium;
use Test::Exception;
use Test::More "no_plan";

my $DEFAULTS = {timeout => 3000};
my $TESTMORE_OUTPUT;

sub new {
  my($class, %args) = @_;

  die 'Must supply a url' unless $args{url};
  
  my $self = {
    _url      => $args{url},
    _host     => $args{host},
    _port     => $args{port},
    _browser  => $args{browser},
    _ua       => $args{ua} || LWP::UserAgent->new(keep_alive => 5, env_proxy => 1),
    _conf     => {},
    _verbose  => $args{verbose},
  };
    
  if (ref $args{conf} eq 'HASH') {
    foreach my $key (keys %{$args{conf}}) {
      $self->{_conf}->{$key} = $args{conf}->{$key};
    }
  }
  
  $self->{_sel} = EnsEMBL::Selenium->new( 
    _ua         => $self->{_ua},
    host        => $self->{_host},
    port        => $self->{_port},
    browser     => $self->{_browser},
    browser_url => $self->{_url},
  );

  bless $self, $class;
  
  $self->sel->set_timeout($self->conf('timeout'));
    
  # redirect Test::More output unless we're in verbose mode
  Test::More->builder->output(\$TESTMORE_OUTPUT) unless ($self->verbose);
    
  return $self;
}

sub url     {$_[0]->{_url}};
sub host    {$_[0]->{_host}};
sub port    {$_[0]->{_port}};
sub browser {$_[0]->{_browser}};
sub ua      {$_[0]->{_ua}};
sub sel     {$_[0]->{_sel}};
sub verbose {$_[0]->{_verbose}};

sub set_default {
  my ($self, $key, $value) = @_;
  $DEFAULTS->{$key} = $value;
}

sub conf {
  my ($self, $key) = @_;
  return $self->{_conf}->{$key} || $DEFAULTS->{$key};
}

sub testmore_output {
  # test builder output (this will be empty if we are in verbose mode)
  return $TESTMORE_OUTPUT;
}

1;