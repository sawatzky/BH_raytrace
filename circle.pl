#!/usr/bin/perl
#$r = 20.;   # pole edge
#$r = 22.26; # EFB
$r = 23.495; # Coil
$c = 3.14159265/180.;
for($deg = 0; $deg <= 360; $deg++)
	{
	$x = $r * cos($deg*$c);
	$y = $r * sin($deg*$c);
	print "$x $y\n";
	}
