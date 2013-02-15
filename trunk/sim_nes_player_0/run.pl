#!/usr/bin/perl
use strict;
use Getopt::Long;

my $altera_lib;
my $bit64;
my $irun_64;
my $irun_cmd;
my $help_promt;
my $nowave;
GetOptions(
    '64bit!' => \$bit64,
    'help' => \$help_promt,
    'nowave!' => \$nowave,
);

if ($help_promt) {
    print '
comand line:
    run.pl [-64bit] [-nowave]


';
    die;
}

if ($bit64==1) {
    $irun_64 = '-64bit' ;
    $altera_lib = '-reflib /workspace/altera_libs/altera64/';
}
else{
    $irun_64 = '';
    $altera_lib = '-reflib /workspace/altera_libs/altera32/';
}

my $dump_wave;
if ($nowave){
    $dump_wave = '';
}
else{
    $dump_wave = '-define DUMP_WAVE';
}
my $para_file = '-f run.para';
my $src_list = '-f file.list';
my $ip_list = '-f ip.list';
my $tb_list = '-f tb.list';
my $c_list = '-f c.list';
my $defines = '-define NCSIM';
my $top = 'tb_nes_player';
$irun_cmd = "irun $irun_64 $defines $dump_wave $altera_lib $para_file $src_list  $ip_list $tb_list $c_list -top $top" ;


system($irun_cmd);

