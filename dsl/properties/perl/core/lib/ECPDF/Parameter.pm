=head1 NAME

ECPDF::Parameter

=head1 DESCRIPTION

This class represents ElectricFlow parameters. It could be:

=over 4

=item B<Configuration Parameters>

=item B<Procedure Parameters>

=back

=head1 SYNOPSIS

Objects of this class have support of toString(). If this object will be used in a string context like:

%%%LANG=perl%%%
    my $parameter = $stepParameters->getParameter('query');
    print "Parameter: $parameter\n";
%%%LANG%%%

getValue() method will be applied automatically and you will get a value instead of reference address.

This object is being returned by L<ECPDF::Config> or L<ECPDF::StepParameters> getParameter() method.

L<ECPDF::StepParameters> object is being returned by getStepParameters() method of L<ECPDF::Context>.

L<ECPDF::Config> object is being returned by getConfigValues method of L<ECPDF::Context>

=head1 METHODS

=over

=item B<getName>

Parameters:

    None

Returns:

    (String) Name of the parameter.

Gets a name from ECPDF::Parameter object.

%%%LANG=perl%%%
    my $parameterName = $parameter->getName();
%%%LANG%%%

=item B<getValue>

Parameters:

    None

Returns:

    (String) Value of the parameter

%%%LANG=perl%%%
    my $parameterValue = $parameter->getValue();
%%%LANG%%%

Also, note, that B<this method is being applied by default, if ECPDF::Parameter object is being used in string context>:

%%%LANG=perl%%%
    # getValue is being applied automatically in string conext. Following 2 lines of code are doing the same:
    print "Query: $query\n";
    printf "Query: %s\n", $query->getValue();
%%LANG

=item B<setName>

Parameters:

    (Required) (String) Parameter Name

Returns

    (ECPDF::Parameter) self

Sets a name for the current parameter. Example:

%%%LANG=perl%%%
    $parameter->setName('myNewName');
%%%LANG%%%

=item B<setValue>

Parameters:

    (Required) (String) Parameter Value

Returns:

    (ECPDF::Parameter) self

%%%LANG=perl%%%
    $parameter->setValue('MyNewValue');
%%%LANG%%%

=back

=cut

package ECPDF::Parameter;
use base qw/ECPDF::BaseClass/;
use overload
    '""' => 'toString';

use strict;
use warnings;


sub classDefinition {
    return {
        name => 'str',
        value => 'str'
    };
}


sub set {
    my ($self, $name, $value) = @_;

    $self->setName($name);
    $self->setValue($value);

    return 1;
}


sub toString {
    my ($self) = @_;

    return $self->getValue();
}

1;
