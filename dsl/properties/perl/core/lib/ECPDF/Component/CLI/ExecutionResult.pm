package ECPDF::Component::CLI::ExecutionResult;
use strict;
use warnings;
use base qw/ECPDF::BaseClass2/;
__PACKAGE__->defineClass({
    stdout => 'str',
    stderr => 'str',
    code   => 'str'
});
use Carp;


1;
