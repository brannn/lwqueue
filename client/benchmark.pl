
# Test the speed and reliability of lwqueue first with 4000 10 byte items
# then with 4000 10,000 byte items.
#
# Warning.. stage one of this benchmark will send/recv approx only 64 kilobytes of data
# Stage two will use approx 64 megabytes of data.. beware if using a slow network connection
# with a remote lwqueue server! If in doubt, comment out the 'exit' further down.

#---
# Example results from my lwqueue running locally on my PowerBook G4 1.67GHz with fastmmap:
#
#   With 10 bytes of data per item:
#    1000 pushes:  2 wallclock secs ( 0.05 usr +  0.04 sys =  0.09 CPU)
#    1000 pops:  2 wallclock secs ( 0.06 usr +  0.03 sys =  0.09 CPU)
#    1000 interleaved:  3 wallclock secs ( 0.12 usr +  0.08 sys =  0.20 CPU)
#
#   With 10000 bytes of data per item:
#    1000 pushes:  4 wallclock secs ( 0.18 usr +  0.08 sys =  0.26 CPU)
#    1000 pops:  2 wallclock secs ( 0.54 usr +  0.08 sys =  0.62 CPU)
#    1000 interleaved:  7 wallclock secs ( 0.75 usr +  0.16 sys =  0.91 CPU)
#---

use Data::Dumper;
use strict;
use Benchmark;
use LWQueue;
use Time::HiRes;

$|++;

my $queue = LWQueue->new('127.0.0.1', 'benchmark');
my $x;


# --- 10 bytes ---

my $s = "0123456789";

print "Starting";

my $t0 = new Benchmark;
	foreach (0..999) {
		$queue->push($s);
	}
	
print ".";

my $t1 = new Benchmark;

	foreach (0..999) {
		$x = $queue->pop;
		if ($x ne $s) { die "contents wrong"; }
	}
	
print ".";

my $t2 = new Benchmark;

	foreach (0..999) {
		$queue->push($s);
		$x = $queue->pop;
		if ($x ne $s) { die "contents wrong"; }
	}

my $t3 = new Benchmark;

print "\n\nWith 10 bytes of data per item:\n";
print " 1000 pushes: " . timestr(timediff($t1, $t0)) . "\n";
print " 1000 pops: " . timestr(timediff($t2, $t1)) . "\n";
print " 1000 interleaved: " . timestr(timediff($t3, $t2)) . "\n\n";

#exit   

# --- 10000 bytes ---

$s = "";
foreach (0..9999) {
	$s .= chr(65 + int(rand(26)));
}

unless (length($s) == 10000) {
	die "Error in string generation";
}

print "Starting";
my $t0 = new Benchmark;
	foreach (0..999) {
		$queue->push($s);
	}

print ".";
my $t1 = new Benchmark;

	foreach (0..999) {
		$x = $queue->pop;
		if ($x ne $s) { die "contents wrong"; }
	}

print ".";
my $t2 = new Benchmark;

	foreach (0..999) {
		$queue->push($s);
		$x = $queue->pop;
		if ($x ne $s) { die "contents wrong"; }
	}

my $t3 = new Benchmark;

print "\n\nWith 10000 bytes of data per item:\n";
print " 1000 pushes: " . timestr(timediff($t1, $t0)) . "\n";
print " 1000 pops: " . timestr(timediff($t2, $t1)) . "\n";
print " 1000 interleaved: " . timestr(timediff($t3, $t2)) . "\n\n";


$queue->close();

