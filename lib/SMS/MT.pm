package SMS::MT;
#### Package information ####
# Description and copyright:
#   See POD (i.e. perldoc SMS::MT).
####

####
# Protected fields:
#	-PLUGIN: Reference to plugin object.
# Constructors:
#	new()
# Public class methods:
#	get_plugin_names()
# Public methods (all plugin modules must implement these methods too):
#	get_last_error_code()
#	get_last_error_message()
#	get_max_text_length()
#	get_service_name()
#	send_groupicon()
#	send_logo()
#	send_picture()
#	send_ringtone()
#	send_text()
####

use strict;
use Carp;
use Exporter();
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(get_plugin_names);
our $VERSION = '0.02';
1;

####
# Constructor new()
# Parameters:
#	Hash containing
#		PLUGIN: name of plugin module to load.
#		UID: user id
#		PWD: pwd
####
sub new {
 my $package = shift;
 my %params = @_;
 my $self  = {};
 bless $self;

 # Check parameters
 my $param_plugin = $params{'PLUGIN'};
 unless(defined($param_plugin)) {
  my $refplugins = &get_plugin_names();
  unless(@{$refplugins}) {
   croak("No plugins installed!\n");
  }
  $param_plugin = $refplugins->[0];
  carp('PLUGIN parameter missing. Defaulting to ' . $param_plugin);
 }
 my $param_uid = $params{'UID'};
 unless(defined($param_uid)) {
  croak("UID parameter missing!\n");
 }
 my $param_pwd = $params{'PWD'};
 unless(defined($param_pwd)) {
  croak("PWD parameter missing!\n");
 }

 # Load plugin module
 $param_plugin = __PACKAGE__ . "::Service::$param_plugin";
 eval("require $param_plugin");
 if ($@) {
  croak "Failed to load plugin module $param_plugin\nException:\n$@";
 }
 $self->{'-PLUGIN'} = $param_plugin->new('UID' => $param_uid, 'PWD' => $param_pwd);

 # Return self reference
 return $self;
}

####
# Class method:	get_plugin_names
# Description:	Builds an array of all available plugins.
# Parameters:	none
# Returns:	(Reference to) an array of plugin names.
####
sub get_plugin_names {
 require FindBin;
 my $path = __FILE__;
 $path =~ s/\.pm$//;
 $path .= '/Service';
 unless(opendir(D,$path)) {
  croak("Failed to open directory $path !\n");
 }
 my @filenames;
 foreach (readdir(D)) {
  if (/(.+).pm$/) {
   push(@filenames,$1);
  }
 }
 closedir(D);
 if (wantarray) {
  return @filenames;
 }
 else {
  return \@filenames;
 }
}

####
# Method:	get_last_error_code
# Description:	Returns the last error code.
# Parameters:	none
# Returns:	String result
####
sub get_last_error_code {
 my $self = shift;
 return $self->{'-PLUGIN'}->get_last_error_code();
}

####
# Method:	get_last_error_message
# Description:	Returns the last error message.
# Parameters:	none
# Returns:	String result
####
sub get_last_error_message {
 my $self = shift;
 return $self->{'-PLUGIN'}->get_last_error_message();
}

####
# Method:	get_max_text_length
# Description:	Get's the maximum text SMS length for the current plugin module.
# Parameters:	none
# Returns:	Max length
####
sub get_max_text_length {
 my $self = shift;
 return $self->{'-PLUGIN'}->get_max_text_length();
}

####
# Method:	get_service_name
# Description:	Get's the current plugin module's service name.
# Parameters:	none
# Returns:	Name
####
sub get_service_name() {
 my $self = shift;
 return $self->{'-PLUGIN'}->get_service_name();
}

####
# Method:	send_groupicon
# Description:	Sends an SMS group icon / CLI / call line identifier.
# Parameters:	1. Reference to binary data buffer containing an OTA bitmap.
#		2. (Reference to) comma seperated string or reference to array of recipients.
#		3. Reference to hash of optional parameters containing any of the keys: FROM, VALIDITY, FLASH, CALLBACK.
# Returns:	Boolean result
####
sub send_groupicon() {
 my $self = shift;
 return $self->{'-PLUGIN'}->send_groupicon(@_);
}


####
# Method:	send_logo
# Description:	Sends an SMS logo.
# Parameters:	1. Reference to binary data buffer containing an OTA bitmap.
#		2. (Reference to) comma seperated string or reference to array of recipients.
#		3. Mobile operator code
#		4. Reference to hash of optional parameters containing any of the keys: FROM, VALIDITY, CALLBACK.
# Returns:	Boolean result
####
sub send_logo() {
 my $self = shift;
 return $self->{'-PLUGIN'}->send_logo(@_);
}

####
# Method:	send_picture
# Description:	Sends an SMS picture.
# Parameters:	1. Reference to binary data buffer containing an OTA bitmap.
#		2. (Reference to) comma seperated string or reference to array of recipients.
#		3. Reference to hash of optional parameters containing any of the keys: FROM, VALIDITY, FLASH, CALLBACK, MSG.
# Returns:	Boolean result
####
sub send_picture() {
 my $self = shift;
 return $self->{'-PLUGIN'}->send_picture(@_);
}

####
# Method:	send_ringtone
# Description:	Sends a ringtone.
# Parameters:	1. (Reference to) RTTTL string.
#		2. (Reference to) comma seperated string or reference to array of recipients.
#		3. Reference to hash of optional parameters containing any of the keys: FROM, VALIDITY, CALLBACK, NAME.
# Returns:	Boolean result
####
sub send_ringtone() {
 my $self = shift;
 return $self->{'-PLUGIN'}->send_ringtone(@_);
}

####
# Method:	send_text
# Description:	Sends an SMS text message.
# Parameters:	1. Text message
#		2. (Reference to) comma seperated string or reference to array of recipients.
#		3. Reference to hash of optional parameters containing any of the keys: FROM, VALIDITY, FLASH, CALLBACK.
# Returns:	Boolean result
####
sub send_text() {
 my $self = shift;
 return $self->{'-PLUGIN'}->send_text(@_);
}

__END__

=head1 NAME

SMS::MT - send mobile terminated SMS messages.

=head1 SYNOPSIS

    use SMS::MT;

    my $sm = new SMS::MT('UID' => 'joeblow',
                         'PWD' => 'secret',
                         'PLUGIN' => 'WirelessServices');

    # Send text message
    unless($sm->send_text('Hello world!',
                          '+31611112222',
                          {'FROM' => 'Joe'})) {
     die "Failed to send SMS.\n" .
         'Error code: ' . $sm->get_last_error_code() . "\n" .
         'Error msg: ' . $sm->get_last_error_message() . "\n";
    }

    # Send picture
    unless($sm->send_picture(\$otadata,
                             '+31611112222',
                             {'FROM' => 'Joe',
                              'MSG' => 'Like my picture?'})) {
     die "Failed to send SMS.\n" .
         'Error code: ' . $sm->get_last_error_code() . "\n" .
         'Error msg: ' . $sm->get_last_error_message() . "\n";
    }

    # Send logo
    unless($sm->send_logo(\$otadata,$mccode,'+31611112222')) {
     die "Failed to send SMS.\n" .
         'Error code: ' . $sm->get_last_error_code() . "\n" .
         'Error msg: ' . $sm->get_last_error_message() . "\n";
    }

    # Send CLI / group icon to 2 recipients
    unless($sm->send_groupicon(\$otadata,'+31611112222,+31600001111')) {
     die "Failed to send SMS.\n" .
         'Error code: ' . $sm->get_last_error_code() . "\n" .
         'Error msg: ' . $sm->get_last_error_message() . "\n";
    }

    # Send ringtone
    my $rtttl = 'Flntstn:d=4,o=5,b=200:g#,c#,8p,c#6,8a#,g#,c#,' .
                '8p,g#,8f#,8f,8f,8f#,8g#,c#,d#,2f,2p,g#,c#,8p,' .
                'c#6,8a#,g#,c#,8p,g#,8f#,8f,8f,8f#,8g#,c#,d#,2c#';
    unless($sm->send_ringtone($rtttl,'+31611112222)) {
     die "Failed to send SMS.\n" .
         'Error code: ' . $sm->get_last_error_code() . "\n" .
         'Error msg: ' . $sm->get_last_error_message() . "\n";
    }


=head1 DESCRIPTION

SMS::MT is a class that uses plugin modules to send mobile terminated SMS
messages via a simple and standard interface. All plugins are accessed
through the methods this class provides.
This way, only one class and it's methods can be used for different SMS MT
services without the user having to go into the details of how each of these
services work.


=head1 CLASS METHODS

=over 4

=item new ('UID' => $userid, 'PWD' => $password, 'PLUGIN' => $plugin);

Returns a new SMS::MT object.

=item get_plugin_names()

Returns a (reference to) an array of installed plugin names depending on the
context in which this method is called.

    Examples:
    my @plugins_array = SMS::MT->get_plugin_names();
    my $plugins_ref = SMS::MT->get_plugin_names();

=back

=head1 OBJECT METHODS

=over 4

=item get_last_error_code()

Returns the last plugin specific error code.

=item get_last_error_message()

Returns the last plugin specific error message.

=item get_max_text_length()

Returns the maximum text length supported by the current plugin.
Normally this is 160.

=item get_service_name()

Get's the current plugin module's descriptive service name.

=item send_groupicon(\$data,$recipients,\%options)

Sends a SMS CLI / group icon.

The first parameter contains a contains a reference to $data, the binary image
data in OTA bitmap format.

The second parameter $recipients contains a comma seperated string or a
reference to an array of recipients in international phone number format.

The third parameter is optional and if present it then it must be a
reference to a hash of options. %options may have any of the following
keys: FROM, VALIDITY, FLASH, CALLBACK, TYPE.

The result contains a boolean value.

=item send_logo(\$data,$recipients,$mccode,\%options);

Sends a SMS operator logo.

The first parameter contains a contains a reference to $data, the binary image
data in OTA bitmap format.

The second parameter $recipients contains a comma seperated string or a
reference to an array of recipients in international phone number format.

The third parameter $mccode must contain the mc code / operator code used that
all recipients belong to. It is up to the caller to ensure that all recipients
in $recipients belong share the same mc code / operator code.

The fourth parameter is optional and if present it then it must be a
reference to a hash of options. %options may have any of the following
keys: FROM, VALIDITY, FLASH, CALLBACK, TYPE.

The result contains a boolean value.

=item send_picture($data,$recipients,\%options)

Sends a SMS picture message. See send_groupicon for parameters and result.

You may also send a text message along with the picture message by adding the
pair 'MSG' => $textmessage to the %options hash.

=item send_ringtone($rtttl,$recipients,\%options)

Sends a SMS ringtone.

The first parameter $rtttl contains (a reference to) a RTTTL string.

The second parameter $recipients contains a comma seperated string or a
reference to an array of recipients in international phone number format.

The third parameter is optional and if present it then it must be a
reference to a hash of options. %options may have any of the following
keys: FROM, VALIDITY, FLASH, CALLBACK, NAME, TYPE.

The result contains a boolean value.

=item send_text($text,$recipients,\%options)

Sends an SMS text message.

The first parameter $text contains the message text.

The second parameter $recipients contains a comma seperated string or a
reference to an array of recipients in international phone number format.

The third parameter is optional and if present it then it must be a
reference to a hash of options. %options may have any of the following
keys: FROM, VALIDITY, FLASH, CALLBACK.

The result contains a boolean value.

=back

=head1 OPTIONAL PARAMETERS TO send*() METHODS

All send*() methods support optional parameters that are passed as a
reference to a hash.

Below is a list of all possible optional parameter keys and what kind of
values are to be associated with them.

=over 4

=item FROM

The value must contain the sender of the message.

=item VALIDITY

The value must contain the validity of the message in minutes.

=item FLASH

The value must contain a boolean indicating if this is a flash SMS.

=item CALLBACK

The value must contain the callback number.

=item NAME

The value must contain the name of the ringtone. This name should override any
name already specified in the RTTTL string.

=item MSG

The value must contain the textual message of a picture message.

=item TYPE

The type of telephone. This is only relevent for non-textual messages.
Examples: NOKIA (default), EMS, MOTOROLA, SAGEM.

=back

=head1 DEVELOPING PLUGINS

=over 4

=item Package name and install location

Plugin modules must be installed in the subdirectory "Service" directly below
the module SMS::MT.pm. The plugin module's package name will therefore be
something like SMS::MT::Service::Foo (the plugin filename being Foo.pm and the
plugin service name being Foo).

=item Required methods

All object methods published in this documentation must be implemented by the
plugin module as all object method calls in the package SMS::MT are passed
through to the plugin module.

The plugin must also have a new() constructor that accepts a hash of parameters
containing keys: UID and PWD. UID is the user id and PWD is the password needed
to login to the SMS service.

=back

=head1 HISTORY

=over 4

=item Version 0.01  2001-10-29

Initial version

=item Version 0.02  2002-01-02

Added TYPE optional parameter.

=back

=head1 AUTHOR

Craig Manley	c.manley@skybound.nl

=head1 COPYRIGHT

Copyright (C) 2001 Craig Manley <c.manley@skybound.nl>.  All rights reserved.
This program is free software; you can redistribute it and/or modify
it under under the same terms as Perl itself. There is NO warranty;
not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut