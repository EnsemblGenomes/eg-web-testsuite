eg-web-testsuite
================

###PREREQUISITES

####Selenium

This testsuite is based on Selenium http://seleniumhq.org/, and requires a Selenium RC server.
Selenium RC requires Java but is otherwise easy to install and run on your local machine, see
http://seleniumhq.org/projects/remote-control/. By default the test scripts expect Selenium RC
to be running on localhost port 4444, but this can be configured.
 
####Perl

This test suite requires Perl with the following modules:
- Class::Inspector
- Getopt::Long
- LWP::UserAgent
- Test::Exception
- Test::More 
- Test::WWW::Selenium
- Time::HiRes


###RUNNING TESTS
  
The test modules are located in <testsuite root>/modules/EnsEMBL/Selenium/Test/

The script to run tests is <testsuite root>/utils/run_tests.pl

To run all tests for a site using the default settings you must specify the name of the test
module and the url of the site to test, e.g.
$ run_tests.pl --module Fungi --url http://fungi.ensembl.org

The following options are also supported:

```
--species_name 
  specify  which species should be tested, e.g.
  $ run_selenium_tests.pl --module Fungi --url http://fungi.ensembl.org --species_name "Aspergillus nidulans"

--timeout 
  specify the default timeout in milliseconds

--test  
  specify one or more tests to run (only these test will be run), e.g.   
  $ run_selenium_tests.pl --module Fungi --url http://fungi.ensembl.org --test attach_das --test upload_data

--skip
  specify one or more tests to skip (all other tests will be run), e.g.   
  $ run_selenium_tests.pl --module Fungi --url http://fungi.ensembl.org --skip attach_das --skip upload_data

--verbose
  show full Test::More output

--host
  specify IP address of Selenium RC server

--port
  specify port number of Selenium RC server
```

###BATCH TESTING
  
1. Update utils/eg_all.conf with any new species from this release. 
2. Comment out sites/species you don't want to test.
3. Run commands:
   $ cd utils
   $ perl run_tests_batch.pl --conf eg_all.conf --host <selenium server ip> --output_dir /path/to/dir/
   

###QUESTIONS
  
eg-webteam@ebi.ac.uk