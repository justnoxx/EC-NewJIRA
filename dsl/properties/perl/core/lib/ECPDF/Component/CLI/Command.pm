package ECPDF::Component::CLI::Command;
use base qw/ECPDF::BaseClass/;
# ECPDF::Component::CLI::Command->defineClass({
#     shell => 'str',
#     args => 'str'
# });

use strict;
use warnings;

use ECPDF::Helpers qw/isWin/;
use ECPDF::Log;
use Carp;

sub classDefinition {
    return {
        shell => 'str',
        args => 'str'
    };
}

sub new {
    my ($class, $shell, @args) = @_;

    logDebug("Creating $class ...\n");
    # TODO: Improve validation here.
    # if (!-f $shell) {
    #     croak "File $shell that is provided to be used as shell does not exist.";
    # }

    @args = escapeArgs(@args);
    $shell = escapeArgs($shell);

    my $self = {
        args => \@args,
        shell => $shell
    };
    bless $self, $class;
    return $self;
    # return $class->SUPER::new({
    #     shell => $shell,
    #     args  => \@args
    # });
}

sub escapeArgs {
    my (@args) = @_;

    # TODO: Add croak if 1st argument is a reference, to be sure that this method is being used as static one.;
    @args = map {
        my $escapeCharacter = isWin() ? q|"| : q|'|;
        s/$escapeCharacter/\\$escapeCharacter/gs;
        $_ = sprintf('%s%s%s', $escapeCharacter, $_, $escapeCharacter);
        $_;
    } @args;
    return $args[0] unless wantarray();
    return @args;
}

sub addArguments {
    my ($self, @args) = @_;

    logDebug("Adding arguments: ". join(', ', @args));
    my $cmdArgs = $self->getArgs();
    for my $arg (escapeArgs(@args)) {
        push @$cmdArgs, $arg;
    }

    return $self;
}

sub renderCommand {
    my ($self, $opts) = @_;

    my $shell = $self->getShell();
    my $args = $self->getArgs();

    my $command = "$shell ";

    my $joinedArgs = join ' ', @$args;

    return $command . $joinedArgs;
}


1;
