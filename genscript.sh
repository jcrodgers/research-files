#!/bin/bash -x

#Change to scratch to hold data - useful if you have large temp storage
cd $SCRATCH
#Create directory to store data
mkdir gen1_results
cd gen1_results

#Temperature in K
temp=313.0

#Pressure in Pa
pres=20e5

#cif Directory - where you have your structures stored
mofs=$HOME/RASPA/simulations/share/raspa/structures/cif

#cif List Location - a vertical list of all cifs in cif Directory
clist=$HOME/generation1/cifList

for ID in $(cat $clist)

do

#Set Cif location

cif=$mofs/$ID.cif

#Find Cell lengths

ca=$(grep cell_length_a $cif|awk '{print $2}')
cb=$(grep cell_length_b $cif|awk '{print $2}')
cc=$(grep cell_length_c $cif|awk '{print $2}')

#Cell Multipliers

cella=$(bc <<< "25.6/$ca +1")
cellb=$(bc <<< "25.6/$cb +1")
cellc=$(bc <<< "25.6/$cc +1")

#Input file for 2 components. Can be tailored to your system
mkdir $ID
cd $ID

#Makes input file for RASPA
cat > simulation.input <<EOF
SimulationType			MonteCarlo
NumberOfCycles			3000
NumberOfInitializationCycles	1000
PrintEvery			200
RestartFile	no

Movies	no

CutOffVDW 12.8
Forcefield			Rodgers2016

UseChargesFromCIFFile	yes

Framework		0
FrameworkName		$ID
UnitCells		$cella $cellb $cellc
ExternalTemperature	$temp
ExternalPressure	$pres

Component 0	MoleculeName			CO2
		MoleculeDefinition		TraPPE
		MolFraction			0.20
		TranslationProbability		0.5
		RegrowProbability		0.5
		IdentityChangeProbability	1.0
		  NumberOfIdentityChanges	1
		  IdentityChangesList		1
		SwapProbability			1.0
		CreateNumberOfMolecules		0

Component 1	MoleculeName			H2
		MoleculeDefinition		TraPPE
		MolFraction			0.8
		TranslationProbability		0.5
		RegrowProbability		0.5
		IdentityChangeProbability	1.0
		  NumberOfIdentityChanges	1
		  IdentityChangesList		0
		SwapProbability			1.0
		CreateNumberOfMolecules		0
EOF

#Slurm Submission file

cat > $ID.job <<EOF
#!/bin/bash -x

#SBATCH --job-name="$ID"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --export=ALL
#SBATCH --time=24:00:00
#SBATCH --partition=gualdron

#Go to job launch directory

cd \$SLURM_SUBMIT_DIR

#Define the path to RASPA exec

EXE=\$HOME/RASPA/simulations/bin/simulate

#Run the exec

srun -n 1 \$EXE simulation.input

EOF
#submit file to HPC where NUMBER is your submission ID
sbatch -A NUMBER $ID.job

cd ..
done
