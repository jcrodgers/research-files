#!/bin/bash -x


#Variables desired
#ID, gravimetric adsorption, volumetric adsorption, heat of adsorption, framework density, energy ro eletrostatic int's, enerfy for VWD int's



#Make CSV file to append
csv=$HOME/generation1
cd $csv
echo "ID,topo,func,gravads0(mol/kg),gravads1(mol/kg),volads0(cm^3STP/cm^3),volads1(cm^3STP/cm^3),entofads0(kJ/mol),entofads1(kJ/mol),fwdens(kg/m^3),mxcoul(K),mxvdw(K),totcoul,totvdw">>gen1.csv

#Go to Data Dir
cd $SCRATCH
cd gen1_results

for ID in $(ls)
do

#check if simulation finished
topo=`echo $ID|cut -c 1-3`

#functionality
functest=`echo $ID | rev | cut -c 5-6 | rev `
func=$( if [[ $functest == *"_"* ]]
then
echo "H"
elif [[ $functest == *"GB"* ]]
then 
echo "B"
elif [[ $functest == *"GM"* ]]
then
echo "M"
else 
echo "$functest"
fi)

#get Grav Adsorption of Comp 0 in mol/kg
gad0=$(grep "Average loading absolute \[mol" $ID/O*/S*/*|tail -3| head -1| awk '{print $6}')

gad1=$(grep "Average loading absolute \[mol" $ID/O*/S*/*|tail -1|awk '{print $6}')

#Vol Ads
vad0=$(grep "Average loading absolute \[cm^3" $ID/O*/S*/*|tail -3|head -1|awk '{print $7}')

vad1=$(grep "Average loading absolute \[cm^3" $ID/O*/S*/*|tail -1|awk '{print $7}')

#Raw Heat of Adsorptionin K
haraw0=$(grep "KJ/MOL" $ID/O*/S*/*|tail -3|head -1| awk '{print $1}')
haraw1=$(grep "KJ/MOL" $ID/O*/S*/*|tail -2|head -1| awk '{print $1}')

ha20_313K0=$(echo "$haraw0 *-1"|bc)
ha20_313K1=$(echo "$haraw1 *-1"|bc)

#Framework Density
fd=$(grep "Framework Density*" $ID/O*/S*/*|head -1|awk '{print $3}')

#Electrostatic energy
ei=$(grep -A 8 "Average Host-Adsorbate energy" $ID/O*/S*/*|tail -1|awk '{print $8}')

#VDW Energy
vdwi=$(grep -A 8 "Average Host-Adsorbate energy" $ID/O*/S*/*|tail -1|awk '{print $6}')

#TotVDW
totv=$(grep "Total Van" $ID/O*/S*/*|tail -1|awk '{print $5}')

#totCoul
totc=$(grep "Total Coul" $ID/O*/S*/*|tail -1|awk '{print $3}')

echo "$ID,$topo,$func,$gad0,$gad1,$vad0,$vad1,$ha20_313K0,$ha20_313K1,$fd,$ei,$vdwi,$totv,$totc" >>$csv/gen1.csv
done
