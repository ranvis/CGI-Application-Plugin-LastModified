use strict;
use warnings;
use Test::More tests => 45;

$ENV{CGI_APP_RETURN_ONLY} = 1;

$ENV{REQUEST_METHOD} = 'GET';

my $app = new_ok('TestApplication');
my $q = $app->query;

my $status200 = qr/^Status: 200 /im;
my $status304 = qr/^Status: 304 /im;
my $status412 = qr/^Status: 412 /im;
my $contentType = qr#^Content-Type: text/html#im;
my $contentAny = qr#^Content-Type: #im;
my $lastModified = qr/^(?i)Last-Modified:(?-i) Sun, 09 Sep 2001 01:46:40 GMT/m;

my ($name, $output);

sub okResponse {
	like($output, $status200, "$name / Status");
	like($output, $contentType, "$name / Content-Type");
	like($output, $lastModified, "$name / Last-Modified");
	like($output, qr/^Output/m, "$name / Content");
}

sub notModifiedResponse {
	like($output, $status304, "$name / Status");
	unlike($output, $contentAny, "$name / Content-*");
	like($output, $lastModified, "$name / Last-Modified");
	unlike($output, qr/^Output/m, "$name / Content");
}

sub preconditionFailedResponse {
	like($output, $status412, "$name / Status");
	unlike($output, $contentAny, "$name / Content-*");
	like($output, $lastModified, "$name / Last-Modified");
	unlike($output, qr/^Output/m, "$name / Content");
}

$name = "Normal request";
delete $ENV{'HTTP_IF_MODIFIED_SINCE'};
$output = $app->run();
okResponse();

$name = "If-Modified-Since request / time before";
$ENV{'HTTP_IF_MODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:39 GMT';
$output = $app->run();
okResponse();

$name = "If-Modified-Since request / the same time";
$ENV{'HTTP_IF_MODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:40 GMT';
$output = $app->run();
notModifiedResponse();

$name = "If-Modified-Since request / time after";
$ENV{'HTTP_IF_MODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:41 GMT';
$output = $app->run();
notModifiedResponse();

$name = "If-Modified-Since request / invalid";
$ENV{'HTTP_IF_MODIFIED_SINCE'} = 'UNPARSABLE_DATE';
$output = $app->run();
okResponse();

delete $ENV{'HTTP_IF_MODIFIED_SINCE'};

$name = "If-Unmodified-Since request / time before";
$ENV{'HTTP_IF_UNMODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:39 GMT';
$output = $app->run();
preconditionFailedResponse();

$name = "If-Unmodified-Since request / the same time";
$ENV{'HTTP_IF_UNMODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:40 GMT';
$output = $app->run();
okResponse();

$name = "If-Unmodified-Since request / time after";
$ENV{'HTTP_IF_UNMODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:41 GMT';
$output = $app->run();
okResponse();

$name = "If-Unmodified-Since request / invalid";
$ENV{'HTTP_IF_UNMODIFIED_SINCE'} = 'UNPARSABLE_DATE';
$output = $app->run();
okResponse();

delete $ENV{'HTTP_IF_UNMODIFIED_SINCE'};

$ENV{REQUEST_METHOD} = 'POST';

$name = "If-Modified-Since POST request / the same time";
$ENV{'HTTP_IF_MODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:40 GMT';
$output = $app->run();
okResponse();
delete $ENV{'HTTP_IF_MODIFIED_SINCE'};

$name = "If-Unmodified-Since POST request / time before";
$ENV{'HTTP_IF_UNMODIFIED_SINCE'} = 'Sun, 09 Sep 2001 01:46:39 GMT';
$output = $app->run();
okResponse();
delete $ENV{'HTTP_IF_UNMODIFIED_SINCE'};

package TestApplication;

use base 'CGI::Application';
use CGI::Application::Plugin::LastModified;

sub setup {
	my $self = shift;
	$self->start_mode('test');
	$self->run_modes(['test']);
}

sub test {
	my $self = shift;
	return if ($self->last_modified(1000000000));
	$self->header_add(-status => '200 OK', -type => 'text/html');
	return "Output";
}
