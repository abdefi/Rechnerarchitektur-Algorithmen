set terminal pngcairo size 800,600 enhanced font 'Verdana,12'
set output 'build/object_file_sizes.png'
set title 'Comparison of Object File Sizes'
set xlabel 'Optimization Level'
set ylabel 'Size (KB)'
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtics nomirror rotate by -45
set xtics ('-g' 1, 'O1' 2, 'O2' 3, 'O3' 4)
set yrange [0:]
set grid ytics
set key off
plot 'build/object_file_sizes.dat' using ($2/1024):xticlabels(1) title 'Object File Sizes'
