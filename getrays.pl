#!/usr/bin/perl

$PI180 = 0.017453293;
# set transformation from initial A coord
# to output coord system
$x_A = 0;
$z_A = -42.26;
$theta_A = 0.;

$energy_save = 0;
$firstray = 0;
$open = 0;
# scan input for elements
# For now just DIPOLE implemented

$el = 0;
while(<STDIN>)
	{
	if($_ =~ /RAY/)
		{
		$firstray = 1;
		last;
		}
	if( $_ =~ /TRANSLATE-ROTATE/)
		{
		<STDIN>;
		$input = <STDIN>;
		@line = split(/\s+/,$input);
		$x0 = $line[3];
		$z0 = $line[9];
		$input = <STDIN>;
		@line = split(/\s+/,$input);
		$psi_y = $line[8];
		$dx[$el][0] = $x0;
		$dz[$el][0] = $z0;
		$th[$el][0] = -$psi_y;
		for($i=1; $i<4; $i++)
			{ $dx[$el][$i]=0; $dz[$el][$i]=0; $th[$el][$i]=0; }
		$el++;
		}
	if( $_ =~ /DIPOLE/)
		{
		<STDIN>;
		$input = <STDIN>;
		@line = split(/\s+/,$input);
		#print $input;
		#print "$line[0] $line[1] $line[2] $line[3] \n";
		$A = $line[3];

		$input = <STDIN>;
		@line = split(/\s+/,$input);
		$B = $line[3];

		<STDIN>;
		$input = <STDIN>;
		@line = split(/\s+/,$input);
		$R = $line[3];

		<STDIN>;
		$input = <STDIN>;
		@line = split(/\s+/,$input);
		$PHI = $line[3];

		$input = <STDIN>;
		@line = split(/\s+/,$input);
		$ALPH = $line[2];

		$input = <STDIN>;
		@line = split(/\s+/,$input);
		$BETA = $line[2];
		#print "A = $A B = $B R = $R PHI = $PHI ALPH = $ALPH BETA = $BETA\n";

		$dx[$el][0] = 0.;
		$dz[$el][0] = 0.;
		$th[$el][0] = 0.;

		$dx[$el][1] = 0.;
		$dz[$el][1] = $A;
		$th[$el][1] = 180.+$ALPH;

		$xtemp = $R * sin($PHI*$PI180);
		$ztemp = $R * (1. - cos($PHI*$PI180));
		$dx[$el][2] = $ztemp*cos($ALPH*$PI180) - $xtemp*sin($ALPH*$PI180);
		$dz[$el][2] = -1.*($xtemp*cos($ALPH*$PI180) + $ztemp*sin($ALPH*$PI180));
		$th[$el][2] = -180. -$ALPH +$PHI -$BETA;

		$dx[$el][3] = -$B*sin($BETA*$PI180);
		$dz[$el][3] = $B*cos($BETA*$PI180);
		$th[$el][3] = $BETA;

		$el++;
		}
	}
# Write a file with the parameters needed
# to convert from the D-axis coordinate system
# to the world system.
open(DAXIS, ">daxis_params.dat") || die "Cannot open file for output\n";
initcoord($x_A, $z_A, $theta_A);
for($e = 0; $e < $el; $e++)
    { for($i = 0; $i < 4; $i++)
	{ setcoord($dx[$e][$i], $dz[$e][$i], $th[$e][$i]); } }
print DAXIS "x_convert= $x_convert\n";
print DAXIS "z_convert= $z_convert\n";
print DAXIS "theta_convert= $theta_convert\n";
print DAXIS "sin_theta= $sin_theta\n";
print DAXIS "cos_theta= $cos_theta\n";
close(DAXIS);

$last_intersection = 0;
while(<STDIN>)
	{
	@words = split(/\s+/);
	$newray = ( $words[0] eq '1' && $words[1] eq 'RAY');
	next if($last_intersection && !$newray);
	if( $firstray || $newray)
		{
		if($firstray) {$ray = 1; $firstray = 0;}
		else { $ray = $words[2]; <STDIN>; }
		$_ = <STDIN>;
		@words = split(/\s+/);
		if($words[1] =~ /ENERGY=/)
			{
			$eng = $words[2];
			if($eng != $energy_save)
				{
				print "Energy = $eng MeV\n";
				$energy_save = $eng;
				}
			}
		if($open) { close(RAY);}
		$filename = "${energy_save}_ray_${ray}.dat";
		open(RAY, ">$filename") || die "Cannot open $filename\n";
		$open = 1;
		print RAY "# Energy $energy_save RAY $ray\n";
		initcoord($x_A, $z_A, $theta_A);
		$element = -1;
		$last_intersection = 0;
		next;
		}
	if($words[2] eq "****")
		{
		# new element
		$element++;
		setcoord($dx[$element][0], $dz[$element][0], $th[$element][0]);
		if($words[1] =~ /TRANSLATE-ROTATE/)
			{
			while (<STDIN>)
				{
				if (/TRANSLATE/)
					{
					<STDIN>;
					$_ = <STDIN>;
					@words = split(/\s+/);
					$X = $words[2];
					$Z = $words[4];
					}
				if (/ROTATE/)
					{
					<STDIN>;
					$_ = <STDIN>;
					@words = split(/\s+/);
					$X = $words[2];
					$Z = $words[4];
					}
				last if /^\s*$/
				}
			print RAY "# TRANSLATE-ROTATE\n";
			printoutput( $X, $Z);
			next;
			}
		elsif($words[1] =~ /DIPOLE/)
			{
			# A axis system
			<STDIN>;<STDIN>;
			print RAY "# NEW DIPOLE A AXIS\n";
			next;
			}
		}
	if($_ =~ / B AXIS SYSTEM/)
		{
		setcoord($dx[$element][1], $dz[$element][1], $th[$element][1]);
		print RAY "# B AXIS\n";
		next;
		}
	if($_ =~ / C AXIS SYSTEM/)
		{
		setcoord($dx[$element][2], $dz[$element][2], $th[$element][2]);
		print RAY "# C AXIS\n";
		next;
		}
	if($_ =~ / D AXIS SYSTEM/)
		{
		setcoord($dx[$element][3], $dz[$element][3], $th[$element][3]);
		print RAY "# D AXIS\n";
		$_ = <STDIN>;
		@words = split(/\s+/);
		$X = $words[3];
		$Z = $words[7];
		printoutput( $X, $Z);
		$_ = <STDIN>;
		@words = split(/\s+/);
		$X = $words[2];
		$Z = $words[4];
		printoutput( $X, $Z);
		next;
		}
	if($_ =~ / INTERSECTION POINT/)
		{
		<STDIN>; $_ = <STDIN>;
		@words = split(/\s+/);
		$X = $words[2];
		<STDIN>; $_ = <STDIN>;
		@words = split(/\s+/);
		$Z = $words[2];
		print RAY "# Intersection point (X,Z) = ($X,$Z)\n";
		printoutput( $X, $Z);
		$last_intersection = 1;
		next;
		}
	if($#words == 12)
		{
		$X = $words[3];
		$Z = $words[7];
		printoutput( $X, $Z);
		next;
		}
		
	}
close(RAY);


# ----------------------------------------------------
sub printoutput {
	my($x, $z) = @_;
	my($x_out, $z_out) = transinit($x,$z);
	my($xx,$yy);
	$xx = -$x_out;
	$yy = $z_out;
	printf RAY "%.4f %.4f\n",$xx, $yy;
	}

sub initcoord {
	my($x_in, $z_in, $th_in) =@_;
	$x_convert = $x_in;
	$z_convert = $z_in;
	$theta_convert = $th_in;
	$theta_rad = $theta_convert * $PI180;
	$sin_theta = sin($theta_rad);
	$cos_theta = cos($theta_rad);
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
sub transinit {
	my($x_in, $z_in) = @_;
	my(@ret);
	
	$ret[0] = $x_in*$cos_theta - $z_in*$sin_theta + $x_convert;
	$ret[1] = $x_in*$sin_theta + $z_in*$cos_theta + $z_convert;
	return(@ret);
	}
