use strict;
use LWQueue;
use Data::Dumper;

my $queue = LWQueue->new('127.0.0.1', 'perltest');

$queue->push("test string");
print $queue->pop;

$queue->push({ 'x' => "testing", 'y' => 'test', 'z' => { 'a' => 1, 'b' => 2 } });
print Dumper($queue->pop);

$queue->close();