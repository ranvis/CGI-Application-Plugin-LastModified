package CGI::Application::Plugin::LastModified;

use warnings;
use strict;
#use Carp;

# keep on one line!
use version 0.77; our $VERSION = qv('v0.1.0');

use Exporter 'import';
our @EXPORT = qw(last_modified);

sub last_modified {
	my ($self, $mtime) = @_;
	require HTTP::Date;
	$self->header_add(-Last_Modified => HTTP::Date::time2str($mtime));
	my $q = $self->query;
	return if ($q->request_method() eq 'POST');
	if (defined(my $time = $q->http('IF_MODIFIED_SINCE'))) {
		$time = HTTP::Date::str2time($time);
		if (defined($time) && $mtime <= $time) {
			$self->header_add(-status => '304 Not Modified');
			$self->header_add(-type => '');
			return 1;
		}
	}
	if (defined(my $time = $q->http('IF_UNMODIFIED_SINCE'))) {
		$time = HTTP::Date::str2time($time);
		if (defined($time) && $mtime > $time) {
			$self->header_add(-status => '412 Precondition Failed');
			$self->header_add(-type => '');
			return 1;
		}
	}
	return;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

CGI::Application::Plugin::LastModified - Modification date handling for CGI::Application


=head1 VERSION

This document describes CGI::Application::Plugin::LastModified version 0.1.0


=head1 SYNOPSIS

    use CGI::Application::Plugin::LastModified;
    
    sub rm {
        my $self = shift;
        return $self->my_status_404 if (my_resource_not_found);
        return if ($self->last_modified((stat(__FILE__))[9]));
        return "Hello World!";
    }


=head1 DESCRIPTION

C<CGI::Application::Plugin::LastModified> provides Last-Modified response
header support for your program.

Additionally this plugin checks If-Modified-Since and If-Unmodified-Since
request headers for GET request, returning appropriate status depending on
your spplied modification date.


=head1 METHODS 

=head2 last_modified($mtime)

Sets last-modified time for the current resource to C<$mtime>,
which should be an epoch value.

If the client requested with either If-Modified-Since or If-Unmodified-Since
header, the method will compare C<$mtime> with it and sets status for you if
appropriate.

Returns 1 if no content should be returned to the client.

If the runmode usually returns non-Successful response (i.e. non-2xx status),
don't call this method. For the details see RFC 2616 section 14.28.


=for =head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=for =over

=for =item C<< Error message here, perhaps with %s placeholders >>

=for [Description of error here]

=for =item C<< Another error message here >>

=for [Description of error here]

=for [Et cetera, et cetera]

=for =back


=head1 DEPENDENCIES

L<CGI::Application>

=head2 Standard Modules

L<version>
L<HTTP::Date>


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<kentaro@ranvis.com>


=head1 AUTHOR

SATO Kentaro  C<< <kentaro@ranvis.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, SATO Kentaro C<< <kentaro@ranvis.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
