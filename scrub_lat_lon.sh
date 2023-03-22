#!/bin/bash
set -x
# Prompt the user to enter the name of the CSV file
read -p "Enter the name of the CSV file: " csv_file

scrubbed_cvs_file=$(pwd)/scrubbed_$(date +"%Y_%m_%d_%I_%M_%p")_$csv_file

raster_file=$(pwd)/gebcodata/gebco_2022_n42.5_s32.5_w-140.5_e-117.5.tif


while IFS=',' read -r sci_name lat lon; do

    # get the pixel coordinates from lat/lon
    px=$(gdallocationinfo -geoloc -valonly $raster_file $lon $lat | awk '{print int($1+0.5)}')
    py=$(gdallocationinfo -geoloc -valonly $raster_file $lon $lat | awk '{print int($2+0.5)}')

    # get the distance to the nearest water body
    distance=$(gdallocationinfo -valonly -wgs84 $raster_file $px $py | awk '{print $1}')

    if [[ !$distance ]]; then
        distance=0
    fi

    # adjust the lat/lon coordinates towards water by moving them towards the nearest water body
    new_lat=$(echo "$lat - (($distance * 0.0001))" | bc -l)
    new_lon=$(echo "$lon + (($distance * 0.0001))" | bc -l)

    echo "Original lat/lon: $lat/$lon"
    echo "New lat/lon: $new_lat/$new_lon"
    echo "$sci_name, $new_lat,$new_lon" >> $scrubbed_cvs_file

done < "$csv_file"


