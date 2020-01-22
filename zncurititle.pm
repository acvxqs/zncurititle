# zncurititle.pm v1.0 by Sven Roelse
# Copycat idea: https://github.com/gryphonshafer/Bot-IRC-X-UriTitle

# Example: 
# https://www.youtube.com/watch?v=c2o4BeOVKoc
# <bot> [ Pearl Jam - Out Of My Mind (Philly '09) - YouTube ]

# 21-01-2020 - v1.0 first draft

use 5.014;
use strict;
use warnings;

use LWP::UserAgent;
use LWP::Protocol::https;
use Text::Unidecode;
use URI::Title;

package zncurititle;
use base 'ZNC::Module';

sub description {
    "ZNC module to parse and print URI titles."
}

sub module_types {
    $ZNC::CModInfo::NetworkModule
}

sub put_chan {
    my ($self, $chan, $msg) = @_;
    $self->PutIRC("PRIVMSG $chan :$msg");
}

sub OnChanMsg {
    my ($self, $nick, $chan, $message) = @_;

    $nick = $nick->GetNick;
    $chan = $chan->GetName;
    # Strip colors and formatting
    if (POE::Component::IRC::Common::has_color($message)) {
        $message = POE::Component::IRC::Common::strip_color($message);
    }
    if (POE::Component::IRC::Common::has_formatting($message)) {
        $message = POE::Component::IRC::Common::strip_formatting($message);
    }
    if ($message=~m|https?://\S+|) {
        my %urls;
        $urls{$1} = 1 while ( $message =~ m|(https?://\S+)|g );
        $self->put_chan($chan,"[ $_ ]") for ( grep { defined } map { Text::Unidecode::unidecode( URI::Title::title($_) ) } keys %urls );
    }
    return $ZNC::CONTINUE;
}
1;
