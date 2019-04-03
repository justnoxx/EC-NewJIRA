=head1 NAME

ECPDF::ComponentManager

=head1 DESCRIPTION

ECPDF::ComponentManager is a class that provides you an access to ECPDF Components infrastructure.

This class allows you to load components depending on you needs.

Currently, there are 2 components loading strategies supported.

=over 4

=item B<Local>

Local component is being loaded to current ECPDF::ComponentManager object context.

So, it is only possible to access it from current object.

=item B<Global>

This is default strategy, component is being loaded for whole execution context and could be accessed from any ECDPF::ComponentManager object.

=back

=head1 METHODS

=over

=cut

package ECPDF::ComponentManager;
use strict;
use warnings;

use Data::Dumper;
use Carp;

use ECPDF::Log;

our $COMPONENTS = {};

=item B<new>

This method creates a new ECPDF::ComponentManager object. It doesn't have parameters.

%%%LANG=perl%%%
    my $componentManager = ECPDF::ComponentManager->new();
%%%LANG%%%

=cut

sub new {
    my ($class) = @_;

    my $self = {
        components_local => {},
    };
    bless $self, $class;
    return $self;
}

=item B<loadComponentLocal>

Loads, initializes the component and returns its as ECPDF::Component:: object in context of current ECPDF::ComponentManager object.

%%%LANG=perl%%%
    $componentManager->loadComponentLocal('ECPDF::Component::YourComponent', {one => two});
%%%LANG%%%

Accepts as parameters component name and initialization values. For details about initialization values see L<ECPDF::Component>

=cut

sub loadComponentLocal {
    my ($self, $component, $params) = @_;

    eval "require $component";
    $component->import();

    my $o = $component->init($params);
    $self->{components_local}->{$component} = $o;
    return $o;
}

=item B<loadComponent>

Loads, initializes the component and returns its as ECPDF::Component:: object in global context.

%%%LANG=perl%%%
    $componentManager->loadComponentLocal('ECPDF::Component::YourComponent', {one => two});
%%%LANG%%%

Accepts as parameters component name and initialization values. For details about initialization values see L<ECPDF::Component>

=cut

sub loadComponent {
    my ($self, $component, $params) = @_;

    logTrace("Loading component $component using params" . Dumper $params);
    eval "require $component" or do {
        croak "Can't load component $component: $@";
    };
    logTrace("Importing component $component...");
    $component->import();
    logTrace("Imported Ok");

    logTrace("Initializing $component...");
    my $o = $component->init($params);
    logTrace("Initialized Ok");
    $COMPONENTS->{$component} = $o;
    return $o;
}


=item B<getComponent>

Returns an ECPDF::Component object that was previously loaded globally. For local context see getComponentLocal

%%%LANG=perl%%%
    my $component = $componentManager->getComponent('ECPDF::Component::Proxy');
%%%LANG%%%

=cut

sub getComponent {
    my ($self, $component) = @_;

    if (!$COMPONENTS->{$component}) {
        croak "Component $component has not been loaded as local component. Please, load it before you can use it.";
    }
    return $COMPONENTS->{$component};
}

=item B<getComponentLocal>

Returns an ECPDF::Component object that was previously loaded in local context.

%%%LANG=perl%%%
    my $component = $componentManager->getComponent('ECPDF::Component::Proxy');
%%%LANG%%%

=cut

sub getComponentLocal {
    my ($self, $component) = @_;

    if (!$self->{components_local}->{$component}) {
        croak "Component $component has not been loaded. Please, load it before you can use it.";
    }
    return $self->{components_local}->{$component};
}

=back

=cut

1;
