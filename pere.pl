#!/usr/bin/env perl

# Simple & Capable bulk file renamer
# https://github.com/anhsirk0/pere

use strict;
use File::Find;
use File::Copy;
use File::Basename;
use Cwd qw(getcwd);
use Getopt::Long;

my @all_files = ();
my @range = ();
my @num_end = ();
my $help;
my $revert;
my $verbose;
my $dry_run;
my $logfile;
my $keep_log;
my $text;
my $search;
my $replace;
my $name;
my $iname;
my $renamed_files_count = 0;
# store initial & final loacation of moved files
my $renamed_files_details = "";

my $w_logfile = "pere_log_" . localtime();
$w_logfile =~ s/ /_/g; # replace spaces with underscores

sub wanted {
    my $name = $File::Find::name;
    my $file = (split "/", $name)[-1];

    if ($file =~ /^\./) { return } # ignore hidden files/dirs

    my $pattern;
    if ($name) {
	$pattern = $name;
    } else {
	$pattern = $iname;	
    }
    
    $pattern =~ s/\*/.*/g; # wildcard to regex
    
    if (-f && $name =~ /^$pattern$/) {
        push(@all_files, $name);
    }
}

sub rename_file {
    my ($file, $new_name) = @_;

    if (-f $new_name) { print "$new_name already exists \n"; return }
    
    my $detail = "$file -> $new_name\n";
    if ($dry_run) { print $detail; return }
    if (move($file, $new_name)) {
	$renamed_files_details .= $detail;
	if ($verbose) { print $detail; }
	$renamed_files_count++;
    }    
}

sub rename_by_numbering {
    # since we are checking terminate condition first
    # and incrementing/decrementing later,
    # this causes the program to return without renaming the last file
    # to overcome this we increment/decrement the range[1] variable
    # before renaming by numbering (see main sub);
    if (scalar @range > 1 && $range[0] == $range[1]) { return }
    
    my  ($f_name, $f_ext) = @_;
    my $new_name = $text;
    $new_name =~ s/\{old\}/$f_name/g;
    $new_name =~ s/\{num\}/$range[0]/g;
    $new_name .= "." . $f_ext;

    my $file = $f_name . "." . $f_ext;
    rename_file($file, $new_name);
    
    if (scalar @range > 1 && $range[0] > $range[1]) {
	$range[0]--;
    } else {
	$range[0]++;
    }
}

sub rename_by_search_replace {
    my  ($f_name, $f_ext) = @_;
    my $new_name = $f_name;

    $new_name =~ s/$search/$replace/g;
    $new_name .= "." . $f_ext;

    my $file = $f_name . "." . $f_ext;
    rename_file($file, $new_name);
}

sub rename_files {
    foreach my $f (@all_files) {
        my $file = (split "/", $f)[-1];

	my ($f_name) = fileparse($file, qr/\.[^.]*/);
	my $f_ext = (split /\./, $f)[-1];

	if ($search && $replace) {
	    rename_by_search_replace($f_name, $f_ext);
	} elsif (scalar @range > 0) {
	    rename_by_numbering($f_name, $f_ext);
	}
    }
}

sub start_rename {
    find({
	wanted => \&wanted,
	 }, getcwd);

    rename_files();
}

sub save_log {
    unless ($renamed_files_details) { return }
    open(FH, ">" . $w_logfile) or die "Unable to open $w_logfile\n";
    print FH $renamed_files_details;
    close(FH);
}

# revert the renaming ; require a $logfile to restore
sub revert_rename {
    unless ($logfile) { print "Log file is required\n"; exit }
    open(FH, '<' . $logfile) or die "Unable to open log file\n";
    while(<FH>) {
        my ($initial, $final) = split " -> ", $_;
	chomp $final;
	rename_file($final, $initial);
    }
}

sub print_help {
    print "usage: pere -name|iname [pattern] [options]\n\n";
    print "-name, --name=STR    specify pattern to find files\n";
    print "-iname, --name=STR    specify pattern to find files (case insensitive)\n";
    print "-n, --num=INT    specify start and ending (optional) numbering\n";
    print "-s, --search=INT    specify search keyword (required with replace)\n";
    print "-r, --replace=INT    specify replace keyword (required with search)\n";
    print "-dry, --dry-run    show what will happen without actually arranging\n";
    print "-v, --verbose    print info while renaming\n";
    print "-rev, --revert    revert the rename (require a logfile)\n";
    print "-log, --logfile=STR    specify logfile (required for reverting)\n";
    print "-no-log    dont save log\n";
    print "-h, --help    show this help message\n";
}

sub main {
    GetOptions (
        "help|h" => \$help,
        "revert" => \$revert,
        "verbose" => \$verbose,
        "dry-run" => \$dry_run,
	"logfile=s" => \$logfile,
        "no-log" => \$keep_log,
	"num|n=i{1,2}" => \@range,
	"text|t=s" => \$text,
	"search|s=s" => \$search,
	"replace|r=s" => \$replace,
        "name=s" => \$name,
        "iname=s" => \$iname
	) or die("Error in command line arguments\n");

    if ($help) { print_help(); exit }

    if ($revert) {
	revert_rename();	
    } elsif (! $name || $iname) {
	print "Must specify -name or -iname to find files \n";
	exit;
    }
    
    if (@range && ! $text) {
	print "Must specify number and text pattern\n";
        print "Example: pere -f 'files*' -n 1 10 -t 'new_file_{num}'\n";
	exit;
    } elsif (($search && ! $replace) || (! $search && $replace)) {
	print "Must specify search text and replace text\n";
        print "Example: pere -name 'files*' -s 'old' -r 'new'\n";
	
	exit;
    }

    # to also include upper/lower bound; see rename_by_numbering sub;
    if (scalar @range > 1) {
	if ($range[0] < $range[1]) {
	    $range[1]++;
	} else {
	    $range[1]--;
	}
    }
    
    start_rename(); # find files and rename;
    
    # write info to a file
    unless ($keep_log || $dry_run) {
        save_log();
    }
    print $renamed_files_count . " Files renamed\n";
}

main();
