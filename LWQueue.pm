# LWQueue
# ---------
# Basic client library for lwqueue in Perl
# --------- (next step, make this POD!)

# Initialization
# 	my $queue = LWQueue->new('127.0.0.1', 'perltest');

# Methods
#	push(data)
#	- Pushes data onto the back of the queue
#
#   pop
#	- Returns data from the head of the queue
#
#	close
#	- Cleanly close the connection to the queue, does not destroy the object though

# Examples
#
#   Putting objects onto the queue
#		$queue->push({ x => "testing", y => "test" });
#
#	Plain text onto the queue
#		$queue->push("whatever")
#
#	Get from the queue
#		$data = $queue->pop;

package LWQueue;

use MIME::Base64;
use IO::Socket;
#use Storable qw(freeze thaw);
use JSON;

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;

	my $address = shift;
	my $queue_name = shift;
	$queue_name =~ s/\-//g;
	return 0 unless ($queue_name =~ /^\S+$/);
	$self->{queue_name} = $queue_name;
	
	my $port;
	if ($address =~ /\:/) {
		($address, $port) = ($address =~ /.+\:\d+/);
	}
	$self->{handle} = IO::Socket::INET->new( Proto     => "tcp",
                                         PeerAddr  => $address,
                                         PeerPort  => $port || 3130 );
	return false unless ($self->{handle});
	$self->{handle}->autoflush(1);
	return $self;
}

sub close {
	my $self = shift;
	$self->{handle}->close();
	return true;
}


sub push {
	my $self = shift;
	my $handle = $self->{handle};

	my $content = shift;
#	$content = "{{serialized-perl}}" . freeze($content) if ref($content);
	$content = "{{serialized-json}}" . objToJson($content) if ref($content);
	my $command = encode_base64("PUSH-" . $self->{queue_name} . "-" . $content);
	
	print $handle $command . "=====\n";
	my $response = <$handle>;

	if ($response =~ /OK/) {
		return 1;
	} else {
		return 0;
	}
}


sub pop {
	my $self = shift;
	my $handle = $self->{handle};

	my $data;

	print $handle encode_base64("POP-" . $self->{queue_name}) . "\n=====\n";
	while (my $response = <$handle>) {
		$data .= $response;
		last if ($response =~ /\=\=\=\=/);
	}

	$data = decode_base64($data);
	
	if ($data =~ /^{{serialized-json}}/) {
		$data =~ s/^{{serialized-json}}//;
#		$data = thaw($data);
		$data = jsonToObj($data);
	}
	
	return $data;
}

1;
