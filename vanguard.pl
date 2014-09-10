# todo: grap topic changes

use strict;
use Data::Dumper;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '0.0.1';
%IRSSI = (
    authors     => 'Joe Talbott',
    contact     => 'joetalbott@gmail.com',
    name        => 'vanguard',
    description => 'Set vanguard in channel topic',
    license     => 'BSD',
    changed     => 'Thu Jun 26 11:42:27 EDT 2014'

);

sub _current_vanguard {
	my $win = Irssi::active_win();
	my $topic = $win->{'active'}->{'topic'};

	my $nick = "";

	if ($topic =~ /.*Vanguard(\s*\([^)]*\)(:|)|)(\s*)([^|]*)\s*\|.*/) {
		$nick = $4;
	}

	return $nick;
}

sub _set_vanguard {
	my ($nick, $channel) = @_;
	my $server = Irssi::active_server();
	my $win = Irssi::active_win();
	my $topic = $win->{'active'}->{'topic'};
	my $name = $win->get_active_name();

	if ($channel eq "") {
		my $chan = Irssi::channel_find($name);
		if ($chan) {
			$channel = $name;
		}
	} else {
		my $chan = Irssi::channel_find($channel);
		if ($chan) {
			$topic = $chan->{'topic'};
		}
	}

	my $chan = Irssi::channel_find($channel);

	$topic =~ s/Vanguard(\s*\([^)]*\)(:|)|)(\s*)[^|]*\s*\|/Vanguard\1 $nick |/;

	my $cmd = "TOPIC $channel :$topic";
	$server->send_raw($cmd) if $chan->{'topic'} ne $topic;
}

sub vanon {
	my $args = @_;
	my $server = Irssi::active_server();
	my $nick = $server->{'nick'};
	_set_vanguard($nick, @_) if $nick ne "";
}

sub vanoff {
	my $server = Irssi::active_server();
	my $nick = $server->{'nick'};

	my $current_vanguard = _current_vanguard();

	if ($nick eq $current_vanguard) {
		_set_vanguard('cihelp', @_);
	} else {
		print("You are not the current vanguard so not setting to 'cihelp'");
	}
}

#--------------------------------------------------------------------
# Irssi::signal_add_last / Irssi::command_bind
#--------------------------------------------------------------------

Irssi::command_bind("vanon", "vanon");
Irssi::command_bind("vanoff", "vanoff");
