#!/usr/bin/perl -w

use Data::Dumper;
use File::Slurp;
use Class::CSV;
use File::Basename;

my @seq_files = <seq_files/*>;

my $output_csv = Class::CSV->new(
	fields => [qw/filename sequence/]
);

for (@seq_files) {
	my $filename = fileparse($_);
	$output_csv->add_line([$filename, get_file_contents($_)]);
}

print "filename,sequence\n";
$output_csv->print();

sub get_file_contents {
	my $file = $_[0];

	my $contents = read_file($file);
	$contents =~ s/[\n\r]//g;
	return($contents);
}
