#!/usr/bin/perl -w

use Data::Dumper;
use File::Slurp;
use Class::CSV;
use File::Basename;

my @seq_files = <plasmid_sequence/*>;
my @read_files = <read_files/*>;

#build up a quick hash of the file numbers in order to map from the file numbers
#in the plasmid sequence files to the associated read files
my %read_file_nums;
my %read_file_full_file;
for (@read_files) {
	if ($_ =~ /(\d+)_/) {
		$read_file_nums{int($1)} = fileparse($_);
		$read_file_full_file{int($1)} = $_;
	} else {
		die "Error finding file number: $_";
	}
}


my $output_csv = Class::CSV->new(
	fields => [('Seq Name', 'Full seq', 'Read 1 name', 'Read 1 seq', 'Read 2 name', 'Read 2 seq')]
);

for (@seq_files) {
	my $filename = fileparse($_);
	my $file_num;
	if ($filename =~ /(\d+)\./) {
		$file_num = int($1);
	} else {
		die "Error finding file number: $_";
	}


	$output_csv->add_line([$filename, 
			get_file_contents($_),
			$read_file_nums{$file_num*2-1},
			get_file_contents($read_file_full_file{$file_num*2-1}),
			$read_file_nums{$file_num*2},
			get_file_contents($read_file_full_file{$file_num*2}),]
		);
}

print "'Seq Name', 'Full seq', 'Read 1 name', 'Read 1 seq', 'Read 2 name', 'Read 2 seq'\n";
$output_csv->print();

sub get_file_contents {
	my $file = $_[0];

	my $contents = read_file($file);
	$contents =~ s/[\n\r]//g;
	return($contents);
}
