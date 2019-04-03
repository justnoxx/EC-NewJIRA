package ECPDF;

=head1 NAME

ECPDF

=head1 AUTHOR

ElectricCloud

=head1 DESCRIPTION

ECPDF is an Electric Cloud Plugin Development Framework.

This tool has been created to make plugin development easier.

To use it one should extend this class and define pluginInfo which should return a hash reference with following fields:

=over 4

=item * B<pluginName>

A name of the plugin. @PLUGIN_KEY@ could be used to be replaced with plugin name during plugin build-time.

=item * B<pluginVersion>

A version of the plugin. @PLUGIN_VERSION@ could be used to be replaced with version during build-time.

=item * B<configFields>

An array reference, that represents fields that would be used by plugin as a reference to plugin configurations.
For example, one could use ['config', 'configName'] to say that config name could be found in these parameter values.

B<IMPORTANT> This list will be used from left to right, so, in example above configName will be used only if there is no procedure parameter with name 'config'.

=item * B<configLocations>

An array reference with locations of plugin configurations. In all new plugins it will be set to ['ec_plugin_cfgs']. Precedence is the same, as in configFields.

=back

=head1 SYNOPSIS

Example of a plugin main class:

%%%LANG=perl%%%
    package EC::Plugin::NewRest;
    use strict;
    use warnings;
    use base qw/ECPDF/;
    # Service function that is being used to set some metadata for a plugin.
    sub pluginInfo {
        return {
            pluginName    => '@PLUGIN_KEY@',
            pluginVersion => '@PLUGIN_VERSION@',
            configFields  => ['config'],
            configLocations => ['ec_plugin_cfgs']
        };
    }
    sub step_do_something {
        my ($pluginObject) = @_;
        my $context = $pluginObject->newContext();
        # This will show where we are. It could be procedure, pipeline or schedule
        print "Current context is: ", $context->getRunContext(), "\n";
        # This will get a step parameters.
        # $params now will be an L<ECPDF::StepParameters> object.
        my $params = $context->getStepParameters();
        # This gets $headers parameter that is being stored under request_headers field of procedure.
        # To get value of this parameter one should 1. get parameter object 2. get a value if it is defined
        my $headers = $params->getParameter('request_headers');
        # This will return a config values for current procedure including credentials.
        # For configuration lookup see section above.
        my $configValues = $context->getConfigValues();
        # This creates a step result object, which handles actions that should be done during or after step execution
        my $stepResult = $context->newStepResult();
        # schedule setting a job step outcome to warning
        $stepResult->setJobStepOutcome('warning');
        # schedule setting a whole job summary:
        $stepResult->setJobSummary("See, this is a whole job summary");
        # schedule setting a current jobstep summary
        $stepResult->setJobStepSummary('And this is a job step summary');
        # abd, finally, apply all scheduled settings.
        $stepResult->apply();
    }
%%%LANG%%%

=head1 ECPDF Crash Course

=head2 Key concepts of ECPDF

=over 4

=item B<ECPDF?>

ECPDF is a B<right> way of doing things that we're, as plugin developerts thinking of.

This SDK implements behind the scene all that is required by 99% of plugins.

That is:

step parameter retrieval, config values retrieval, multiple credentials in configuration and procedure parameters,
code organization, pipeline results setup, output parameters setup, etc.

Also, this SDK provides a way of integration with ElectricFlow without deep and sometimes painfull knowledge of EF caveats.

=item B<Plugin API>

After generation you will see that your plugin has single main class created, which inherits ECPDF.
This file will be at dsl/properties/perl/lib/EC/Plugin/__YOURCLASS__.pm.

For each procedure of your plugin, function in this file will be created during generation.
To see, which function is for which procedure, visit dsl/procedures/__YOUR_PROCEDURE__/steps/__YOUR_PROCEDURE__.pl you will see something like:

%%%LANG=perl%%%
    $[/myProject/perl/core/scripts/preamble.pl]
    use EC::Plugin::NewRest;
    # Auto generated code of plugin step
    EC::Plugin::YOURCLASS->runStep('YOURPROCEDURE', 'YOURPROCEDURESTEP', 'functionName');
%%%LANG%%%

In your main plugin class is function called functionName is already defined. It will be:

%%%LANG=perl%%%
    sub functionName {
        my ($pluginObject) = @_;
        ...;
    }
%%%LANG%%%

That's it. Now, using this plugin object you can write your own logic.

=item B<Context>

Almost everything that we're doing during plugin development is context-dependent.

When we retrieving pipeline parameters, we're doing it in coontext of current pipeline run.

Pipeline parameters don't have any value outside of this pipeline. Same for configuration. Same for step parameters.
We're interested in them only during current procedure or pipeline run. That's why the key concept of ECPDF SDK is Context.

Context is being created from plugin object using newContext() method. This context is a way of doing context dependent things (they are 99%).

Like that:

%%%LANG=perl%%%
    my $context = $pluginObject->newContext();
%%%LANG%%%

=item B<Retrieving Step Parameters for the current run>

After we have a context object, we can retrieve a step parameters using getStepParameters function.

%%%LANG=perl%%%
    my $parameters = $context->getStepParameters();
%%%LANG%%%

Now, parameters are L<ECPDF::StepParameters> object.

Let's say, that we have a credential parameter called credential, that we need for some reason.
Also, let's say that we have an 'url' parameter, that is mandatoty, and 'method' parameter, that is optional.
Now, to get them we may want to write a piece of code that like that:

%%%LANG=perl%%%
    my $cred = $parameters->getParameter('credential');
    my $url = $parameters->getParameter('url')->getValue();
    my $method = undef;
    if (my $p = $parameters->getParameter('method')) {
        $method = $p->getValue();
    }
    my ($username, $password);
    if ($cred) {
        $username = $cred->getUserName();
        $password = $cred->getSecretValue();
    }
%%%LANG%%%

Also, you need to know that credential parameter is slightly different from parameter.
When we retrieving parameter, that is parameter, we have a L<ECPDF::Parameter> as a result.
But when we retrieving credentials, L<ECPDF::Credential> is being returned.

If parameter of credential does not exist, undefined value is returned.

To get a value from L<ECPDF::Parameter> object one need to call a getValue() method.

Since we plan to have a different types of credentials, we're using username and secret value combination.

So, currently, to get a username and password from plugin parameters, getUserName and getSecretValue functions have to be used.

=item B<Retrieving config values for the plugin>

In ElectricFlow plugin configurations are just a sets of properties. The difference is in context again.

You may want to think of plugin configurations as a global values for a whole plugin.

To get config values from configuration for current step one need to do a simple call of getConfigValues. Like that:

    my $configValues = $context->getConfigValues();

Now, configValues is an L<ECPDF::Config object>.

It has the same interface as L<ECPDF::StepParameters>.

What is interesting about this call is that you don't need to pass a configuration name. It will figure out this by itself.
How?

Let's take a closer look at your main class.

On the top of it you can see something like:

%%%LANG=perl%%%
    sub pluginInfo {
        return {
            pluginName    => '@PLUGIN_KEY@',
            pluginVersion => '@PLUGIN_VERSION@',
            configFields  => ['config'],
            configLocations => ['ec_plugin_cfgs'],
        }
    }
%%%LANG%%%

That's it. You can see that plugin definition has configFields and configLocations properties.

Config fields defines a step parameter name where configuration name is being stored, configLocations is the place, where configurations are stored.

Why it is an array reference? It is because you may have in a different procedures a different name of config parameters.
It is not a best practice, and it is not recommended to do it so, but for backward compatibility reason it is possible that names are different.
This applies for previously created plugins.

B<No new plugins should have a different names for a config parameter.>

So, basically, newConfigValues is smart enough to go, check your config parameters to get a config name, and go the config locations and retrieve this config.

That's why this function does not have any parameters for now.

The logic is simple. Once you calling something through context object - it is context dependent. Config retrieval through context returns a config values for current context.

Simple as that.

=item B<Setting step results>

After you finished execution of your procedure, or even during it, you may want to set properties, output parameters, summary, otcomes, etc.

There is a good way of doing that. It is L<ECPDF::StepResult>.

L<ECPDF::StepResult> is a class, that represents a handlers for step results. It is designed to be a queue.

Typical workflow for L<ECPDF::StepResult> is:

1. One creates an object using context.
2. One sets an action items using its functions.
3. One applies changes.

So, let's take an example:

%%%LANG=perl%%%
    # Step 1. Creating an object.
    my $stepResult = $context->newStepResult();
    # Step 2. Adding action items.
    $stepResult->setOutputParameter('executionResult', 'Successfully finished!');
    $stepResult->setJobStepSummary('Done with success');
    # Step 3. Applying changes.
    $stepResult->apply();
%%%LANG%%%

For more details about available function, please, visit L<ECPDF::StepResult>

=item B<Performing REST requests>

To perform rest request one need to get a L<ECPDF::Client::REST> object.

As usual, this object is being created through context object. Like that:

%%%LANG=perl%%%
    # retrieving new rest client object.
    my $restClient = $context->newRESTClient();
    # creating HTTP::Request object using our wrappers
    my $req = $restClient->newRequest(GET => 'https://localhost:8080');
    # performing request and getting HTTP::Response obhject.
    my $response = $restClient->doRequest($req);
    # printing response content:
    print $response->decoded_content();
%%%LANG%%%

=item B<CLI execution>

ECPDF allows you to execute system commands using its interface. It is being shipped with few components.
One of them is a component for cli. It is called ECPDF::Component::CLI.

To do that, following steps have to be performed.

1. Load component.
2. Create CLI executor.
3. Create command.
4. Run command.
5. Process response.

Following example illustrates it:

%%%LANG=perl%%%
    # Step 1 and 2. Loading component and creating CLI executor with working directory of current workspace.
    my $cli = ECPDF::ComponentManager->loadComponent('ECPDF::Component::CLI', {
        workingDirectory => $ENV{COMMANDER_WORKSPACE}
    });
    # Step 3. Creating new command with ls as shell and -la as parameter.
    my $command = $cli->newCommand('ls', ['-la']);
    # adding to more parameters for command
    $command->addArguments('-lah');
    $command->addArguments('-l');
    # Step 4. Executing a command
    my $res = $cli->runCommand($command);
    # Step 5. Processing a response.
    print "STDOUT: " . $res->getStdout();
%%%LANG%%%

=back

=head1 METHODS

=cut

use base qw/ECPDF::BaseClass/;
use strict;
use warnings;

use Carp;
use Data::Dumper;

use ECPDF::Service::Bootstrap;
use ECPDF::ContextFactory;
use ECPDF::ComponentManager;


our $VERSION = '1.0.4';

sub classDefinition {
    return {
        pluginName      => 'str',
        pluginVersion   => 'str',
        configFields    => '*',
        configLocations => '*',
        contextFactory  => '*',
        pluginValues    => '*'
    };
}

=over

=item B<newContext>

Creates L<ECPDF::Context> object. Does not require any additional parameters.

%%%LANG=perl%%%
    my $context = $pluginObject->newContext();
%%%LANG%%%

=back

=cut


sub newContext {
    my ($pluginObject) = @_;

    return $pluginObject->getContextFactory()->newContext($pluginObject);
}
sub util {}
sub pluginInfo {}

sub runStep {
    my ($class, $procedureName, $stepName, $function) = @_;

    if (!$class->can($function)) {
        croak "Class $class does not define function $function\n";
    }
    if (!$class->can('pluginInfo')) {
        croak "Class $class does not have a pluginInfo function defined\n";
    }
    my $pluginInfo = $class->pluginInfo();

    # TODO: add validation for pluginInfo fields.
    my $ecpdf = $class->new({
        pluginName      => $pluginInfo->{pluginName},
        pluginVersion   => $pluginInfo->{pluginVersion},
        configFields    => $pluginInfo->{configFields},
        configLocations => $pluginInfo->{configLocations},
        contextFactory  => ECPDF::ContextFactory->new({
            procedureName => $procedureName,
            stepName      => $stepName
        })
    });

    # if pluginvalues has been passed, it will be added to plugin object.
    if ($pluginInfo->{pluginValues}) {
        $ecpdf->setPluginValues($pluginInfo->{pluginValues});
    }

    return $ecpdf->$function();
}

=head1 SEE ALSO

=head2 L<ECPDF::Context>

=head2 L<ECPDF::StepResult>

=head2 L<ECPDF::Config>

=cut

1;
