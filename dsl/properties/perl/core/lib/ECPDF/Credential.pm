=head1 NAME

ECPDF::Credential

=head1 DESCRIPTION

This class represents a credential of ElectricFlow.

What is credential in ElectricFlow?

In ElectricFlow credentials are special secured containers for secret values.

=head1 ELECTRIC FLOW CREDENTIALS NAMING CONVENTION

Credentials in electricflow should be named in 2 ways:

=over 4

=item B<credential>

This is default one that is being used as first credential.

=item B<%name%_credential>

In that case credential parameter should be named as %action%_credential.

For example, for proxy username and proxy password B<proxy_credential> parameter should be used.

=back

ECPDF has support of both patterns.

=head1 SYNOPSIS

%%%LANG=perl%%%
    # retrieving parameter of current plugin configuration.
    # in this case credentals is a parameter named credential.
    my $cred = $cofigValues->getParameter('credential');
    # getting type of credential. It is default, private_key, etc,
    my $credentialType = $cred->getCredentialType();
    my $userName = $cred->getUserName();
    my $password = $cred->getSecretValue();
    my $credentialName = $cred->getCredentialName();
%%%LANG%%%

=head1 METHODS

=over

=item B<getCredentialType>

Returns different values for different credentials type. For ECPDF SDK Drop1 only default is supported.

It does not mean, that you can't access credentials of any type with that API.

It means, that currently all credentials are being processed as default ones: username and password, but these fields are optional.

%%%LANG=perl%%%
    my $credType = $cred->getCredentialType();
%%%LANG%%%

=item B<getUserName>

Returns a user name that is being stored in the current credential.

%%%LANG=perl%%%
    my $userName = $cred->getUserName();
%%%LANG%%%

=item B<getSecretValue>

Returns a secret value that is being stored in the current credential.

=item B<getCredentialName>

Returns a name for the current credential.

%%%LANG=perl%%%
    my $credName = $cred->getCredentialName();
%%%LANG%%%

=back

=cut

package ECPDF::Credential;
use base qw/ECPDF::BaseClass/;
use strict;
use warnings;

sub classDefinition {
    return {
        credentialName => 'str',
        credentialType => 'str',
        userName => 'str',
        secretValue => 'str',
    }
}

1;
