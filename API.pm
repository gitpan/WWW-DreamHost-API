package WWW::DreamHost::API;

# $Id: API.pm 8 2009-10-18 11:43:13Z stro $

use strict;
use warnings;
use Carp;

our $VERSION = '1.01';

use LWP::UserAgent;
use Data::UUID;

=head1 NAME

WWW::DreamHost::API - Perl interface to DreamHost Web Panel API

=head1 VERSION

1.01

=head1 SYNOPSIS

 my $key = '6SHU5P2HLDAYECUM';
 my $api = new WWW::DreamHost::API($key);
 my $res = $api->command('api-list_accessible_cmds');
 print Data::Dumper->Dump([$res]);

=head1 DESCRIPTION

WWW::DreamHost::API provides a simple Perl interface to DreamHost Web Panel API.

Read more about API commands at L<http://wiki.dreamhost.com/Application_programming_interface>

=head1 METHODS

=head2 new ( $key )

Creates WWW::DreamHost::API object

=cut

sub new {
    my $class = shift;
    my $key   = shift;

    croak 'You should provide a key in order to use WWW::DreamHost::API' unless defined $key;

    my $self = {
        '__key'  => $key,
        '__ua'   => LWP::UserAgent->new('agent' => 'WWW-DreamHost-API/' . $VERSION),
        '__ug'   => new Data::UUID,
        '__uniq' => int(rand(time())),

    };

    $self->{'__ua'}->env_proxy();

    bless $self, $class;
    return $self;
}

=head2 uuid ( )

Returns UUID. Probably actually unique (randomly based on key and run time).
Don't worry, if it's not, because it's reinitializing in case of failure (though I cannot imagine how it can happen).

=cut

sub uuid {
    my $self = shift;
    my $uuid = $self->{'__ug'}->create_from_name('WWW-DreamHost-API-'. $self->{'__key'}, $self->{'__uniq'}++);
    return $self->{'__ug'}->to_string($uuid);
}

=head2 reinit ( )

If unique check fails, attempt to re-initialize. You don't have to call it yourself.

=cut

sub reinit {
    my $self = shift;
    $self->{'__uniq'} = int(rand(time()));
    return 1;
}

=head2 command ( $cmd, [ $param => $value, ]+ )

Execute a command. 

To get a list of availible commands, use something like that:

    my $res = $api->command('api-list_accessible_cmds');
    if ($res->{'success'}) {
        my @commands = @{ $res->{'data'} };
    }

Returns a hash reference with (usually) 'result' and 'data' keys. 'result' can be 'success' or 'error', and 'data' depends on command executed.

See L<http://wiki.dreamhost.com/Application_programming_interface> for more details.

=cut

sub command {
    my $self = shift;
    my $cmd = shift;
    my %extraparam = @_;
    delete $extraparam{$_} foreach (qw/ key cmd unique_id format /); # fool-proof

    while (1) {
        # Loop until UUID is unique. Though I'm VERY doubtful this can happen in real life.

        my $res = $self->{'__ua'}->post('https://api.dreamhost.com/', {
            'key'       => $self->{'__key'},
            'cmd'       => $cmd,
            'unique_id' => $self->uuid(),
            'format'    => 'perl',
            %extraparam,
        });

        if ($res->is_success()) {
            my $result;
            eval $res->content();
            if ($@) {
                eval { die $@; };
                return;
            } else { 
                if ($result->{'result'} eq 'error' and $result->{'data'} eq 'unique_id_already_used') {
                    $self->reinit();    # Reinitialize random seed
                    redo;               # Send another request
                }
                return $result;
            }
        } else {
            eval { die $res->status_line(); };
            return;
        }
    }
}

=head1 CONFIGURATION AND ENVIRONMENT

WWW::DreamHost::API is based on I<libwww-perl> which uses I<Crypt::SSLeay>
or I<IO::Socket::SSL>, with all consequences: HTTPS_proxy environment
variable and so on. See I<LWP> documentation unless you're already familiar
with it.

=head1 DEPENDENCIES

LWP::UserAgent
Crypt::SSLeay
Data::UUID

=head1 INCOMPATIBILITIES

Not known.

=head1 BUGS AND LIMITATIONS

Not known, but test suite MAY fail if DreamHost adds some other commands or
change their behaviour.
If you are using L<CPAN::Reporter> in your service, I'll know about it.
Consider installing it, as it really helps authors to know about possible bugs.
See L<http://wiki.cpantesters.org/wiki/QuickStart>.

=head1 AUTHOR

Serguei Trouchelle L<stro@railways.dp.ua>

=head1 LICENSE AND COPYRIGHT

This module is distributed under the same terms as Perl itself.

Copyright (c) 2009 Serguei Trouchelle

=cut

1;