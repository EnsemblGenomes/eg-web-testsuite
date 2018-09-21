package EnsEMBL::Selenium::Test::Ensembl;
use strict;
use base 'EnsEMBL::Selenium::Test::Base';

__PACKAGE__->set_default('species', 'Homo_sapiens');

sub test_nav_links {
  my $self = shift;
  my $sel = $self->sel;
  
  my $js_set_ids = "\$('a', '.local_context').each(function(index) { \$(this).attr('id', 'nav_test_' + index); })";
  
  foreach my $entity ('region', 'gene', 'transcript', 'variant', 'phenotype', 'structural variant', 'regulatory feature') {
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

1;