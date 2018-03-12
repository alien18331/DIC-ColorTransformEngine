#!/bin/sh

name="CTE"

echo "run $name project ..."

if [ -d "Documentary_category" ]; then
    rm -r Documentary_category
    echo "remove Documentary_category/"
fi
if [ -d "RTL_category" ]; then
    rm -r RTL_category
    echo "remove RTL_category"
fi
if [ -d "Gate-Level_category" ]; then
    rm -r Gate-Level_category
    echo "remove Gate-Level_category/"
fi
if [ -f "$name.vo" ]; then
    rm $name.vo
    echo "remove $name.vo"
fi
if [ -f "${name}_v.sdo" ]; then
    rm ${name}_v.sdo
    echo "remove ${name}_v.sdo"
fi
if [ -f "$name.v" ]; then
    rm $name.v
    echo "remove $name.v"
fi
unzip HW5_P76061386_沈育同_v*.zip
cp RTL_category/$name.v $name.v
echo "copy $name.v"
cp Gate-Level_category/${name}_v.sdo ${name}_v.sdo
echo "copy ${name}_v.sdo"
cp Gate-Level_category/$name.vo $name.vo
echo "copy $name.vo"
echo "successfully"
