#!/usr/bin/perl
#
# read the parameters
open(DAXIS, "daxis_params.dat") || die "Cannot open daxis_params.dat\n";
while(<DAXIS>)
	{
	@word = split /\s+/;
	if($word[0] =~ /x_convert=/) {$x_convert = $word[1];}
	if($word[0] =~ /z_convert=/) {$z_convert = $word[1];}
	if($word[0] =~ /theta_convert=/) {$theta_convert = $word[1];}
	if($word[0] =~ /sin_theta=/) {$sin_theta = $word[1];}
	if($word[0] =~ /cos_theta=/) {$cos_theta = $word[1];}
	}
#print "$x_convert $z_convert\n";
#rint "$theta_convert $sin_theta $cos_theta\n";
close(DAXIS);
$axislength = 50.;
open(OUT, ">daxis.dat") || die "cannot open for output\n";
$z = 0.; $x = $axislength;
printoutput($x, $z);
$z = 0.; $x = 0.;
printoutput($x, $z);
$z = $axislength; $x = 0.;
printoutput($x, $z);
close(OUT);

open(OUT, ">focalplane.dat") || die "cannot open for output\n";
open(FOCAL, "focaldaxis.dat") || die "cannot open focaldaxis.dat\n";
while(<FOCAL>)
	{
	@line = split(/\s+/);
	$x = $line[1];
	$z = $line[2];
	printoutput($x, $z);
	}
close(FOCAL);
close(OUT);

sub transinit {
	my($x_in, $z_in) = @_;
	my(@ret);
	
	$ret[0] = $x_in*$cos_theta - $z_in*$sin_theta + $x_convert;
	$ret[1] = $x_in*$sin_theta + $z_in*$cos_theta + $z_convert;
	return(@ret);
	}
sub printoutput {
	my($x, $z) = @_;
	my($x_out, $z_out) = transinit($x,$z);
	my($xx,$yy);
	$xx = -$x_out;
	$yy = $z_out;
	printf OUT "%.4f %.4f\n",$xx, $yy;
	}

