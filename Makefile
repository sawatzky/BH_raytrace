#FFLAGS= -O
FFLAGS= -fugly-assumed -fugly-comma -pedantic -fbounds-check -fno-automatic

raytrace: ray.o
	g77 ray.o -o raytrace

install: raytrace
	mv raytrace ~/bin

clean:
	rm *.o
