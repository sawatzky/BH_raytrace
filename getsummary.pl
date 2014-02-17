#!/usr/bin/perl
#
$energy_save = 0 ;
open(FOC, ">focaldaxis.dat") || die "Cannot open output file\n";
while(<STDIN>)
	{
	@words = split(/\s+/);
	if($words[1] =~ /ENERGY=/)
		{
		$eng = $words[2];
		if($eng != $energy_save)
			{
			if($energy_save != 0){ printaverage(); }	
			print "Energy = $eng MeV\n";
			$energy_save = $eng;
			$n_eng = 0;
			}
		}
	if( $_ =~ /INTERSECTION POINT/)
		{
		$_=<STDIN>;
		if($_ =~ /D AXIS/)
			{
			$_ = <STDIN>;
			@words = split(/\s+/);
			if($words[1] =~ /XXINT=/)
				{$x = $words[2];}
			$_ = <STDIN>;
			@words = split(/\s+/);
			if($words[1] =~ /YYINT=/)
				{$y = $words[2];}
			$_ = <STDIN>;
			@words = split(/\s+/);
			if($words[1] =~ /ZZINT=/)
				{$z = $words[2];}
			}
		print "Intersection (x,y,z) = ($x, $y, $z) cm\n";
		$x_eng[$n_eng] = $x;
		$y_eng[$n_eng] = $y;
		$z_eng[$n_eng] = $z;
		$n_eng++;
		}
	}
printaverage();
close(FOC);

sub printaverage
	{
	$xx = 0; $yy = 0; $zz = 0;
	for($i = 0; $i < $n_eng; $i++)
		{
		$xx += $x_eng[$i];
		$yy += $y_eng[$i];
		$zz += $z_eng[$i];
		}
	$xx /= ($n_eng);
	$yy /= ($n_eng);
	$zz /= ($n_eng);
	print "     Average (x,y,z) = ($xx, $yy, $zz) cm\n";
	print FOC "$energy_save $xx $zz\n";
	}
