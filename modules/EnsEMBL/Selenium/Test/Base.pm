package EnsEMBL::Selenium::Test::Base;
use strict;
use base 'EnsEMBL::Selenium::Test';
use Test::More;

__PACKAGE__->set_default('timeout', 50000);

sub upload_data {
  my ($self, $format, $name, $data) = @_;
  my $sel = $self->sel;
  print "Uploading $format data: $name\n";
  $sel->click_ok('link=Custom tracks')
  and $sel->pause(10000)
  and $sel->click_ok('link=Add more data')
  and $sel->pause(10000)
  and $sel->type_ok("name=name", $name)
  and $sel->type_ok("name=text", $data)
  and $sel->pause(10000)
  and $sel->select_ok("name=format", "label=$format")
  and $sel->ensembl_wait_for_ajax_ok
  and $sel->click_ok("name=submit_button")
  and $sel->wait_for_text_present_ok("region with data")
  and $sel->click_ok("xpath=//div[\@id='UploadParsed']//a") # click the first region link
  and $sel->ensembl_wait_for_ajax_ok;
}

sub open_species_homepage {
  my ($self) = @_;
  my $sel = $self->sel;
  $sel->open($sel->{browser_url} . '/' . $self->conf('species'))
  and $sel->ensembl_wait_for_page_to_load_ok;
}

sub click_link {
  my ($self, $locator, $timeout) = @_;
  my $sel = $self->sel;
  $sel->click_ok($locator)
  and $sel->ensembl_wait_for_page_to_load_ok($timeout || $self->conf('timeout'));
}

1;
