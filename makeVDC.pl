#!/usr/bin/perl
#
# VDC Dimensions
#  short side in dispersive plane
#$width = 10.06;
#$length = 91.4;
#$end_length = 19.1;
#$wire_in = $width/3.; # guess
#$VDC2_offset_z = 39.4;
#$VDC2_offset_x = 39.4;
# long side in dispersive plane
$width = 10.06;
$length = 243.84;
$end_length = 19.7;
$wire_in = $width/3.; # guess
$VDC2_offset_z = 39.4;
$VDC2_offset_x = 0.;

$shift_up = 60.;
#$rotate_angle = 17.66; # deg
#$rotate_angle = 90. -28.25; # deg
$rotate_angle = 0.; # deg


$PI180 = 0.017453293;
# Edge points in its own frame of reference
# centered on first wire active area
# z perpendicular to chamber

$z[0] = -$wire_in;
$x[0] = -$length/2;

$z[1] = $z[0] + $width;
$x[1] = $x[0];

$z[2] = $z[1];
$x[2] = -$x[1];

$z[3] = $z[2] - $width;
$x[3] = $x[2];

$z[4] = $z[0];
$x[4] = $x[0];

$z[5] = $z[4];
$x[5] = $x[4] + $end_length;

$z[6] = $z[5] + $width;
$x[6] = $x[5];

$z[7] = $z[6];
$x[7] = -$x[6];

$z[8] = $z[7] - $width;
$x[8] = $x[7];

$z[9] = 0.;
$x[9] = $x[8];

$z[10] = 0.;
$x[10] = -$x[9];

$z[11] = -$wire_in + $width - $wire_in;
$x[11] = $x[10];

$z[12] = $z[11];
$x[12] = -$x[11];

$offset_z = 0.;
$offset_x = 0;

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
#print "$theta_convert $sin_theta $cos_theta\n";
close(DAXIS);

open(OUT, ">VDC.dat") || die "Cannot open file for output\n";
setcoord(0., 0., $rotate_angle);

for($i = 0; $i < 13; $i++)
	{
	$X = $x[$i] + $shift_up;
	$Z = $z[$i];
	printoutput($X, $Z);
	}
close(OUT);
open(OUT, ">VDC2.dat") || die "Cannot open file for output\n";

for($i = 0; $i < 13; $i++)
	{
	$X = $x[$i] + $shift_up + $VDC2_offset_x;
	$Z = $z[$i] + $VDC2_offset_z;
	printoutput($X, $Z);
	}
close(OUT);

sub transinit {
	my($x_in, $z_in) = @_;
	my(@ret);
	
	$ret[0] = $x_in*$cos_theta - $z_in*$sin_theta + $x_convert;
	$ret[1] = $x_in*$sin_theta + $z_in*$cos_theta + $z_convert;
	return(@ret);
	}
sub setcoord {
	my($x_in, $z_in, $th_in) = @_;
	($x_convert, $z_convert) = transinit($x_in, $z_in);
	$theta_convert += $th_in;
	while($theta_convert > 180.) { $theta_convert -= 360.; }
	while($theta_convert < -180.) { $theta_convert += 360.; }
	$theta_rad = $theta_convert * $PI180;
	$sin_theta = sin($theta_rad);
	$cos_theta = cos($theta_rad);
	}
sub printoutput {
	my($x, $z) = @_;
	my($x_out, $z_out) = transinit($x,$z);
	my($xx,$yy);
	$xx = -$x_out;
	$yy = $z_out;
	printf OUT "%.4f %.4f\n",$xx, $yy;
	}

