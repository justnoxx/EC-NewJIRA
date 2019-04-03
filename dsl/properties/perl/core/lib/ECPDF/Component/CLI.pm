package ECPDF::Component::CLI;
use base qw/ECPDF::BaseClass2/;

ECPDF::Component::CLI->defineClass({
    workingDirectory    => 'str',
    resultsDirectory    => 'str',
    componentInitParams => '*',
});

use strict;
use warnings;
use ECPDF::Helpers qw/isWin genRandomNumbers/;
use ECPDF::Component::CLI::Command;
use ECPDF::Component::CLI::ExecutionResult;
use ECPDF::Log;
use Carp;


sub init {
    my ($class, $params) = @_;

    if (!$params->{workingDirectory}) {
        croak "Working Directory is expected for CLI interface initialization\n";
    }

    if (!$params->{resultsDirectory}) {
        $params->{resultsDirectory} = $params->{workingDirectory};
    }
    return $class->new($params);
}

sub newCommand {
    my ($self, $shell, $args) = @_;

    my $command = ECPDF::Component::CLI::Command->new($shell, @$args);

    return $command;
}


sub runCommand {
    my ($self, $command, $mergeOut) = @_;

    $mergeOut ||= 0;
    logInfo("Running command: " . $command->renderCommand());
    if (my $wd = $self->getWorkingDirectory()) {
        chdir($wd) or croak "Can't chdir to $wd";
    }
    return $self->_syscall($command, $mergeOut);

}

sub _syscall {
    my ($self, $commandObject, $mergeOut) = @_;

    my $command = $commandObject->renderCommand();
    my $result_folder = $self->getResultsDirectory();
    my $stderr_filename = 'command_' . genRandomNumbers(42) . '.stderr';
    my $stdout_filename = 'command_' . genRandomNumbers(42) . '.stdout';
    $command .= qq| 1> "$result_folder/$stdout_filename" 2> "$result_folder/$stderr_filename"|;
    if (isWin) {
        logDebug("MSWin32 detected");
        $ENV{NOPAUSE} = 1;
    }

    my $pid = system($command);
    my $retval = {
        stdout => '',
        stderr => '',
        code => $? >> 8,
    };

    open (my $stderr, "$result_folder/$stderr_filename") or croak "Can't open stderr file ($stderr_filename) : $!";
    open (my $stdout, "$result_folder/$stdout_filename") or croak "Can't open stdout file ($stdout_filename) : $!";
    $retval->{stdout} = join '', <$stdout>;
    $retval->{stderr} = join '', <$stderr>;
    close $stdout;
    close $stderr;

    # Cleaning up
    unlink("$result_folder/$stderr_filename");
    unlink("$result_folder/$stdout_filename");

    my $result = ECPDF::Component::CLI::ExecutionResult->new($retval);
    return $result;
}




1;

