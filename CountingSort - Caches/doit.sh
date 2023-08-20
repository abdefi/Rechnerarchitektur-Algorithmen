#!/bin/bash

# Function to generate objdump for a target
generate_objdump() {
    local target=$1
    local obj_output_dir="${BUILD_DIR}/${target}"
    local instruction_file="${obj_output_dir}/${target}_instruction.txt"
    mkdir -p "${obj_output_dir}"
    objdump -d -S "${obj_output_dir}/${target}.o" > "${instruction_file}"
    echo "Generating objdump for ${target}"
}

# Function to extract size information from object files
extract_size_info() {
    local target=$1
    local output_dir=$2
    local object_file="${output_dir}/${target}.o"
    local size_info=$(ls -l "${object_file}" | awk '{ print $5 }')
    echo "${size_info}"
}

# Function to build and generate objdump for a target
build_and_generate_objdump() {
    local target=$1
    local output_dir=$2
    local optimization=$3
    local source_file="countingsort.c"
    local object_file="${output_dir}/${target}.o"
    local instruction_file="${output_dir}/${target}_instruction.txt"
    local perf_output_file="${output_dir}/${target}_perf_output.txt"
    
    # Build the object file
    gcc -c "${source_file}" -o "${object_file}" -Wall "${optimization}"
    
    # Apply chmod to the object file
    chmod +x "${object_file}"
    
    generate_objdump "${target}"
    
    # Run perf stat for the object file and write the output to a text file
    perf stat "./${object_file}" > "${perf_output_file}" 2>&1
}





# Function to apply chmod to object files
apply_chmod() {
    local target=$1
    local output_dir=$2
    local object_file="${output_dir}/${target}.o"
    chmod +x "${object_file}"
}

# Create build directory if it doesn't exist
BUILD_DIR="build"
mkdir -p "${BUILD_DIR}"

# Build and generate objdump for each target
build_and_generate_objdump "counting_sort" "${BUILD_DIR}/counting_sort" "-g"
build_and_generate_objdump "counting_sort_O1" "${BUILD_DIR}/counting_sort_O1" "-O1"
build_and_generate_objdump "counting_sort_O2" "${BUILD_DIR}/counting_sort_O2" "-O2"
build_and_generate_objdump "counting_sort_O3" "${BUILD_DIR}/counting_sort_O3" "-O3"

# Apply chmod to object files
apply_chmod "counting_sort" "${BUILD_DIR}/counting_sort"
apply_chmod "counting_sort_O1" "${BUILD_DIR}/counting_sort_O1"
apply_chmod "counting_sort_O2" "${BUILD_DIR}/counting_sort_O2"
apply_chmod "counting_sort_O3" "${BUILD_DIR}/counting_sort_O3"

# Extract size information for each object file
counting_sort_size=$(extract_size_info "counting_sort" "${BUILD_DIR}/counting_sort")
counting_sort_O1_size=$(extract_size_info "counting_sort_O1" "${BUILD_DIR}/counting_sort_O1")
counting_sort_O2_size=$(extract_size_info "counting_sort_O2" "${BUILD_DIR}/counting_sort_O2")
counting_sort_O3_size=$(extract_size_info "counting_sort_O3" "${BUILD_DIR}/counting_sort_O3")

# Generate the gnuplot script
generate_gnuplot_script() {
    local output_dir=$1
    local data_file="${output_dir}/object_file_sizes.dat"
    local plot_script="${output_dir}/gnuplot_script.gp"

    # Generate the data file
    cat << EOF > "${data_file}"
counting_sort ${counting_sort_size}
counting_sort_O1 ${counting_sort_O1_size}
counting_sort_O2 ${counting_sort_O2_size}
counting_sort_O3 ${counting_sort_O3_size}
EOF

    # Generate the gnuplot script
    cat << EOF > "${plot_script}"
set terminal pngcairo size 800,600 enhanced font 'Verdana,12'
set output '${output_dir}/object_file_sizes.png'
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
plot '${data_file}' using (\$2/1024):xticlabels(1) title 'Object File Sizes'
EOF
}

# Generate the gnuplot script and execute
generate_gnuplot_script "${BUILD_DIR}"
gnuplot "${BUILD_DIR}/gnuplot_script.gp"
