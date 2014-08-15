package EnsEMBL::Selenium::Test::Homepage;
use strict;
use base 'EnsEMBL::Selenium::Test';

__PACKAGE__->set_default('timeout', 30000);

sub test_id_resolver {
  my $self = shift;
  my $sel = $self->sel;
    
  # eg! gene id -> gene summary page
  $sel->open_ok("/id/AT1G54990")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Arabidopsis thaliana')
  and $sel->is_text_present_ok('Gene summary');
  
  # eg! gene id -> location view page
  $sel->open_ok("/id/AT1G54990/location_overview")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Arabidopsis thaliana')
  and $sel->is_text_present_ok('Region in detail');
  
  # ensembl gene id -> ensembl gene summary
  $sel->open_ok("/id/ENSG00000139618")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Human')
  and $sel->is_text_present_ok('Gene summary');
  
  # eg! multi-match -> search results page
  $sel->open_ok("/id/AT3G52430.1")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Search Results Summary')
  and $sel->is_text_present_ok('PAD4')
  and $sel->is_text_present_ok('Peptide AT3G52430.1')
  and $sel->is_text_present_ok('Transcript AT3G52430.1');
  
  # eg! multi-match -> gene summary
  $sel->open_ok("/id-gene/AT3G52430.1")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Arabidopsis thaliana')
  and $sel->is_text_present_ok('Gene summary');
  
  # eg! multi-match -> transcript summary
  $sel->open_ok("/id-transcript/AT3G52430.1")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Arabidopsis thaliana')
  and $sel->is_text_present_ok('Transcript summary');
  
  # eg! multi-match -> protein summary
  $sel->open_ok("/id-peptide/AT3G52430.1")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Arabidopsis thaliana')
  and $sel->is_text_present_ok('Protein summary');
  
  # eg! genetree id -> default site genetree page
  $sel->open_ok("/id-genetree/EGGT00050000013744")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('GeneTree EGGT00050000013744')
  and $sel->is_text_present_ok('Ensembl Metazoa');
  
  # eg! genetree id + gene -> site-specific genetree page
  $sel->open_ok("/id-genetree/EGGT00050000013744/gene/DDB_G0280897")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('GeneTree EGGT00050000013744')
  and $sel->is_text_present_ok('Ensembl Protists');
  
  # ensembl genetree id -> ensembl genetree page
  $sel->open_ok("/id-genetree/ENSGT00390000003602")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('GeneTree')
  and $sel->is_text_present_ok('Ensembl release');
  
  # multi transcript
  $sel->open_ok("/id/LOC_Os06g04200.4")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Search Results Summary')
  and $sel->is_text_present_ok('LOC_Os06g04200.1')
  and $sel->is_text_present_ok('LOC_Os06g04200.2')
  and $sel->is_text_present_ok('LOC_Os06g04200.3')
  and $sel->is_text_present_ok('LOC_Os06g04200.4');
  $sel->open_ok("/id/LOC_Os06g04200")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Gene: WX1')
  and $sel->is_text_present_ok('Plants');
  
  # single result in e! and eg! - redirect to eg! by default
  $sel->open_ok("/id/FBtr0114370")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Transcript: eys-RC')
  and $sel->is_text_present_ok('Ensembl Metazoa');
  
  # bad id -> search
  $sel->open_ok("/id/ThisIsNotAnId")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Search Results Summary');
  
  # bad genetree id -> search
  $sel->open_ok("/id-genetree/ThisIsNotAnId")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Search Results Summary');
  
  # case sensetivity
  $sel->open_ok("/id/spac1f7.05")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Gene: cdc22')
  and $sel->is_text_present_ok('Ensembl Fungi');
  $sel->open_ok("/id/SPAC1F7.05")
  and $sel->wait_for_page_to_load_ok("30000")
  and $sel->is_text_present_ok('Gene: cdc22')
  and $sel->is_text_present_ok('Ensembl Fungi');
}

1;