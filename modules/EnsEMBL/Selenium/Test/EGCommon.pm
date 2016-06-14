package EnsEMBL::Selenium::Test::EGCommon;
use strict;
use base 'EnsEMBL::Selenium::Test';
use Test::More;

__PACKAGE__->set_default('timeout', 50000);

#------------------------------------------------------------------------------
# TESTS
#------------------------------------------------------------------------------

sub test_sitemap_index {
  my ($self) = @_;
  return unless $self->check_live; 
  my $sel = $self->sel; 
  my $response = $sel->ua->get("$sel->{browser_url}/sitemap-index.xml");
  ok($response->is_success, 'Request for sitemap was successful')
  and ok($response->decoded_content !~ /404 error/m, 'Ensembl did not show 404 error')
  and ok($response->decoded_content =~ /sitemapindex/, "First line contains 'sitemapindex'");
}

sub test_robots_file {
  my ($self) = @_;
  return unless $self->check_live; 
  my $sel = $self->sel;
  $sel->open("/robots.txt") 
  and $sel->is_text_present_ok('Disallow:*/')
  and $sel->is_text_present_ok('Sitemap');  
}

sub test_search_all { # cant run this on test sites as ebeye 'ensembl' domain not present on test 
  my ($self) = @_;
  return unless $self->check_live; 
  my $sel = $self->sel;
  $sel->open_ok("/")
  and $sel->click_ok("//div[\@id='searchPanel']//img[2]") # open search menu
  and $sel->click_ok("se_ensembl_all") 
  and $sel->type_ok("se_q", "brca2")
  and $sel->click_ok("//input[\@type='image']")
  and $sel->ensembl_wait_for_page_to_load_ok
  and $sel->is_element_present_ok("//div[\@class='hit']");
}

sub test_search_species {
  my ($self) = @_;
  my $sel = $self->sel;
  $self->open_species_homepage
  and $sel->click_ok("//a[contains(\@href,'psychic?')]") # click first example search 
  and $sel->ensembl_wait_for_page_to_load_ok
  and $sel->is_element_present_ok("//div[\@class='hit']");
}

sub test_nav_links {
  my $self = shift;
  my $sel = $self->sel;
  
  my $js_set_ids = "\$('a', '.local_context').each(function(index) { \$(this).attr('id', 'nav_test_' + index); })";
  
  foreach my $entity ('region', 'gene', 'transcript', 'variant') {
    print ucfirst($entity) . "...\n";
    
    $self->open_species_homepage,
    and $self->click_link("link=Example $entity");
    
    $sel->run_script($js_set_ids);
    
    my @ids = $sel->get_all_links;
    
    foreach my $id (grep {/^nav_test_/} @ids) {
      $sel->run_script($js_set_ids);
      my $href = $sel->get_eval("selenium.browserbot.getCurrentWindow().jQuery('a#$id').attr('href')");
      next unless $href =~ /^\//; # don;t test external urls
      print "$href\n";
      $self->click_link("id=$id");
    }
  }
}

sub test_upload_data {
  my $self = shift;
  my $sel = $self->sel;
  
  $self->open_species_homepage
  and $sel->click_ok('link=Example region')
  and $sel->ensembl_wait_for_page_to_load_ok();
  
  my ($chr, $start, $end) = $sel->get_location() =~ /r=(.+):([0-9]+)-([0-9]+)$/;
  
  if ($chr and $start and $end) {
    my ($s, $e) = ($start, $start + 100 < $end ? $start + 100 : $end);
    
    my $data = qq{
##gff-version\t3
##sequence-region\t$chr\t1\t1090947
$chr\tEnsembl\tgene\t$s\t$e\t.\t-\t.\tID=TEST;Name=TEST;biotype=protein_coding
$chr\tEnsembl\ttranscript\t$s\t$e\t.\t-\t.\tID=TEST;Name=TEST;Parent=TEST;biotype=protein_coding
$chr\tEnsembl\texon\t$s\t$e\t.\t-\t0\tName=TEST.1;Parent=TEST
    };
    
    $self->upload_data('GFF3', 'example_gff3', $data);
  }
}

sub test_attach_bam {
  my $self = shift;
  my $sel = $self->sel;
  
  my $bam_url = 'ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/pilot_data/data/NA06984/alignment/NA06984.454.MOSAIK.SRP000033.2009_11.bam';
  
  $self->open_species_homepage
  and $sel->click_ok("link=Example region")
  and $sel->ensembl_wait_for_page_to_load_ok()
  and $sel->click_ok('link=Custom tracks')
  and $sel->ensembl_wait_for_ajax_ok
  and $sel->pause(10000)
  and $sel->type_ok("name=text", $bam_url)
  and $sel->pause(10000)
  and $sel->click_ok("name=submit_button")
  and $sel->ensembl_wait_for_ajax_ok(100000,10000) #timeout=50s and pause=10s
  and $sel->pause
  and $sel->wait_for_text_present_ok("successfully attached")
  and $sel->pause
  and $sel->click("css=div.modal_close")
  and $sel->ensembl_wait_for_ajax_ok(undef,10000);
}

# added in response to http://www.ebi.ac.uk/panda/jira/browse/ENSEMBL-751
sub test_export_data {
  my ($self, $links) = @_;
  my $sel = $self->sel;

  $self->open_species_homepage
  and $sel->pause(10000)
  and $sel->click_ok("link=Example region");
  $sel->pause(10000);
  $sel->click_ok("link=Export data");
  $sel->ensembl_wait_for_ajax_ok;
  $sel->pause(10000);
  $sel->select_ok("name=output", "value=gff");
  $sel->pause(10000);
  $sel->ensembl_wait_for_ajax_ok
  and $sel->click_ok("name=next")
  and $sel->ensembl_wait_for_ajax_ok
  and $sel->pause
  and $sel->pause(10000)
  #and $sel->click_ok("link=HTML")                                                 # can't do this as opens in new window, so...
  and $sel->open_ok( $sel->get_attribute(q{//div[@id='Formats']//li[1]/a/@href}) ) # get href and open the url in current window
  and $sel->ensembl_wait_for_ajax_ok;
}

#------------------------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------------------------

sub check_live {
  my $self = shift;
  if (!$self->conf('live')) {
    print "Skipping - this test only runs in live environment (use --live)\n";
  }
  return $self->conf('live');
}

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
  and $sel->wait_for_text_present_ok("Go to nearest region with data")
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
