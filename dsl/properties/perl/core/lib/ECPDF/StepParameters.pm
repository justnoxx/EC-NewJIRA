=head1 NAME

ECPDF::StepParameters

=head1 DESCRIPTION

This class represents current step parameters, that are defined for current procedure step or current pipeline task.

=head1 SYNOPSIS

To get an ECPDF::StepParameters object you need to use newStepParameters() method from L<ECPDF::Context>.

=head1 METHODS

=over

=cut

package ECPDF::StepParameters;
use base qw/ECPDF::BaseClass/;
use strict;
use warnings;

sub classDefinition {
    return {
        parametersList => '*',
        parameters => '*'
    };
}

# sub isParameterExists {};
# sub getParameter {};
# sub setParameter {};
# sub setCredential {};
# sub getCredential {};


=item B<isParameterExists>

Returns true if parameter exists in the current step.

%%%LANG=perl%%%
    if ($stepParameters->isParameterExists('query')) {
        ...;
    }
%%%LANG%%%

=cut

sub isParameterExists {
    my ($self, $parameterName) = @_;

    my $p = $self->getParameters();
    if ($p->{$parameterName}) {
        return 1;
    }
    return 0;
}

=item B<getParameter>

Returns an L<ECPDF::Parameter> object or L<ECPDF::Credential> object.

To get parameter object:

%%%LANG=perl%%%
    my $query = $stepParameters->getParameter('query');
%%%LANG%%%

If your parameter is an L<ECPDF::Parameter> object, you can get its value either by getValue() method, or using string context:

%%%LANG=perl%%%
    print "Query:", $query->getValue();
%%%LANG%%%

Or:

%%%LANG=perl%%%
    print "Query: $query"
%%%LANG%%%

If your parameter is L<ECPDF::Credential>, follow its own documentation.

=cut

sub getParameter {
    my ($self, $parameterName) = @_;

    if (!$self->isParameterExists($parameterName)) {
        return undef;
    }

    return $self->getParameters()->{$parameterName};
}

=back

=cut

1;
