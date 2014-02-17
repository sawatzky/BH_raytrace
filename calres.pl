#!/usr/bin/perl
use Math::Trig;

$matrix_filename = shift || "output-46";
open( MAT, $matrix_filename) || die "Cannot open file $matrix_filename\n";
while(<MAT>)
	{
	last if /TRANSFORM/;
	if ($_ =~ /MOMENTUM/)
		{
		@mat = split(/\s+/);
		$momentum = $mat[4];
		}
	}
$line = <MAT>; @mat =split(/\s+/,$line);
$x_x = $mat[1]; $x_t = $mat[2]; $x_d = $mat[6];
$line = <MAT>; @mat =split(/\s+/,$line);
$t_x = $mat[1]; $t_t = $mat[2]; $t_d = $mat[6];
$line = <MAT>; @mat =split(/\s+/,$line);
$y_y = $mat[3]; $y_p = $mat[4];
$line = <MAT>; @mat =split(/\s+/,$line);
$p_y = $mat[3]; $p_p = $mat[4];
close(MAT);

print "First order matrix elements.\n";
printf "%12.5f %12.5f %12.5f %12.5f %12.5f\n",$x_x,$x_t,0.,0.,$x_d;
printf "%12.5f %12.5f %12.5f %12.5f %12.5f\n",$t_x,$t_t,0.,0.,$t_d;
printf "%12.5f %12.5f %12.5f %12.5f %12.5f\n",0.,0.,$y_y,$y_p,0.;
printf "%12.5f %12.5f %12.5f %12.5f %12.5f\n",0.,0.,$p_y,$p_p,0.;

$denom = $x_d * $t_t - $x_t * $t_d;
$num_delta = $x_x * $t_t - $x_t * $t_x;
$delta_x0 = -$num_delta / $denom;
$delta_xf = $t_t / $denom;
$delta_tf = $x_t / $denom;
$energy_x0 = $delta_x0/100. * $momentum;
$energy_xf = $delta_xf/100. * $momentum;
$energy_tf = $delta_tf/100. * $momentum;
print "\n";
printf "Momentum = %.1f MeV/c\n",$momentum;
printf "DELTA_momentum / x_0 = %10.3f %/cm",$delta_x0;
printf "  = %10.3f MeV/cm\n",$energy_x0;
printf "DELTA_momentum / x_f = %10.3f %/cm",$delta_xf;
printf "  = %10.3f MeV/cm\n",$energy_xf;
printf "DELTA_momentum / t_f = %10.3f %/mr",$delta_tf;
printf "  = %10.3f MeV/mr\n",$energy_tf;

$num_theta = $x_x * $t_d - $t_x * $x_d;
$theta_x0 = $num_theta / $denom;
$theta_xf = -$t_d / $denom;
$theta_tf = $x_d / $denom;
$PI_180 = 3.14159265/180.;
$degree_x0 = $theta_x0/1000./$PI_180;
$degree_xf = $theta_xf/1000./$PI_180;
$degree_tf = $theta_tf;
printf "DELTA_angle / x_0 =    %10.3f mr/cm",$theta_x0;
printf " = %10.3f deg/cm\n",$degree_x0;
printf "DELTA_angle / x_f =    %10.3f mr/cm",$theta_xf;
printf " = %10.3f deg/cm\n",$degree_xf;
printf "DELTA_angle / t_f =    %10.3f      ",$theta_tf;
printf " = %10.3f \n",$degree_tf;

# Append to files for transfer coefficients
$fileout = "trans_dEdx0.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $energy_x0; close(OUT);
$fileout = "trans_dEdxf.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $energy_xf; close(OUT);
$fileout = "trans_dEdtf.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $energy_tf; close(OUT);
$fileout = "trans_dTdx0.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $degree_x0; close(OUT);
$fileout = "trans_dTdxf.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $degree_xf; close(OUT);
$fileout = "trans_dTdtf.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $degree_tf; close(OUT);

$d_x = 0.1;
#$d_x = 0;
$ch_sep = 40.;
$d_theta_mr = atan(1.4*$d_x/$ch_sep)*1000.;
$d_theta_deg = $d_theta_mr/1000./$PI_180;
$beam_spot_radius = 0.6;
#$beam_spot_radius = 0;

$del_energy_sq = ($energy_x0*$beam_spot_radius)**2;
$del_energy_sq += ($energy_xf*$d_x)**2;
$del_energy_sq += ($energy_tf*$d_theta_mr/1000.)**2;
$del_energy = sqrt($del_energy_sq);
$del_degree_sq = ($degree_x0*$beam_spot_radius)**2;
$del_degree_sq += ($degree_xf*$d_x)**2;
$del_degree_sq += ($degree_tf*$d_theta_deg)**2;
$del_degree = sqrt($del_degree_sq);

$fileout = "Resolution_energy.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $del_energy; close(OUT);
$fileout = "Resolution_angle.dat";
open(OUT, ">>$fileout") || die "Cannot open $fileout for appending.\n";
printf OUT "%.2f %.3f\n", $momentum, $del_degree; close(OUT);


print "\nResolutions assuming:\n";
printf "    Beam spot radius = %.1f mm\n", $beam_spot_radius*10.;
printf "    Wire chamber position resolution = %.2f mm\n", $d_x*10.;
printf "    Wire chamber seperation = %.1f cm\n", $ch_sep;
printf "    (-> Angular resolution = %.2f degrees)\n",$d_theta_deg;
printf "Energy resolution = %.2f MeV\n", $del_energy;
printf "Angle resolution = %.2f Deg.\n", $del_degree;
