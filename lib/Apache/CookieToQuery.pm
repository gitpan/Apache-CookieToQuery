package Apache::CookieToQuery;
use strict;

BEGIN {
	use Exporter ();
	use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION     = 1.02;
	@ISA         = qw (Exporter);
	#Give a hoot don't pollute, do not export more than needed by default
	@EXPORT      = qw ();
	@EXPORT_OK   = qw ();
	%EXPORT_TAGS = ();
}

use Apache;
use CGI qw();
use Apache::Cookie;
use constant CONFIG_COOKIE_INCLUDE => q{IncludeCookie};
use constant CONFIG_COOKIE_ALIAS => q{CookieAlias};
use constant CONFIG_ALIAS_SEP => q{:};

our ( @COOKIE_NAMES, %COOKIE_ALIASES );

########################################### main pod documentation begin ##

=head1 NAME

Apache::CookieToQuery - Rewrite query string by adding cookie information

=head1 SYNOPSIS

  In httpd.conf or similiar
 
  <Location /YourLocation>
	PerlAddVar IncludeCookie SiteID
	PerlAddVar IncludeCookie SessionID
	PerlAddVar IncludeCookie PageId
	PerlAddVar CookieAlias WSID:SiteId
	PerlAddVar CookieAlias SID:SessionId
	PerlAddVar CookieAlias PID:PageId
	PerlFixupHandler Apache::CookieToQuery	
  </Location>

=head1 DESCRIPTION

 This module will aid in adding cookie information to your query strings
 so that cgi scripts or handlers underneath can have immidate benefit

 It requires mod_perl + Apache web server with PERL_FIXUP callback hook enabled
 for more information refer on callback hooks refer to: 
 http://perl.apache.org/docs/1.0/guide/install.html#Callback_Hooks

 IncludeCookie specifies cookie names that will be added, if none are specified
 any cookie name is taken into consideration

 CookieAlias specifies cookie name to look for and cookie name to alias it with 
 when query string is rewritten, if alias for a cookie name does not exist, 
 original cookie name will be used 

 Please note that in the current implementation cookies always take precedence 
 over query string paramaters 


=head1 BUGS

 If you find any, please let the author know

=head1 AUTHOR

	Alex Pavlovic
	CPAN ID: ALEXP
	alex-1@telus.net
	

=head1 COPYRIGHT

Copyright (c) 2002 Alex Pavlovic. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=head1 PUBLIC METHODS

Each public function/method is described here.
These are how you should interact with this module.

=cut

############################################# main pod documentation end ##

################################################ subroutine header begin ##

=head2 handler

 Usage     : handler ( $apache ) 
 Purpose   : rewrites the query string of the original request
 Returns   : nothing for now
 Argument  : apache instance
 Throws    : nothing for now
 Comments  : 
           : 

See Also   : 

=cut

################################################## subroutine header end ##

sub handler {
	my $apache = shift;
	my $cgi = CGI->new ( { $apache->args } );
	my $cookies = Apache::Cookie->new( $apache )->fetch;
        %COOKIE_ALIASES = split CONFIG_ALIAS_SEP, join CONFIG_ALIAS_SEP, $apache->dir_config ( CONFIG_COOKIE_ALIAS ) unless %COOKIE_ALIASES;
	@COOKIE_NAMES = $apache->dir_config ( CONFIG_COOKIE_INCLUDE ) unless @COOKIE_NAMES;
	my $cookie_names = @COOKIE_NAMES ? 
		\@COOKIE_NAMES : 
			[ keys %$cookies ];
	$cookies->{$_} and $cgi->param ( ( $COOKIE_ALIASES{$_} or $_ ), $cookies->{$_}->value ) for @$cookie_names;
	$apache->args ( $cgi->query_string );
}

1; #this line is important and will help the module return a true value
__END__


