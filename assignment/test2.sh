#!/bin/bash

access_pattern_flag=${17}	# 0 is default access pattern
_wio=1
_2d=2
_hmc=0

num_cores=16
#core_freq=2.1
banks=128
layers=8
num_channels=16
hotspot_run=1				#
is_2_5d=0					# Is the stacked memory being used in 2.5D configuration. 2.5 D config is ONLY available for HMCs.
sniper_simulation=0			# If 0, keep the tmp and sim.out file in the folder with appropriate names

declare -A matrix

#for (( t=0; t<$num_channels; t++ ))
for (( t=0; t<1; t++ ))
do  
	sniper_log_3D_prefix="tmp128_3D_"
	sniper_log_2D_prefix="tmp128_2D_"
	bench_list="List of benchmarks,"
	IPS="IPS Performance(3D),"
	Core_power="Core Power(3D),"
	Logic_Core_power="Logic Core Power(3D),"
	LC_Power=""
	leakage=""
	Bank_power="Bank Power(3D),"
	Max_bank_temp=""
	LC_temp="LC Temperature,"
	core_temp="Core Temperature(3D),"

	MBT="Maximum Bank Temperature(3D),"
	MLcT="Maximum LC Temperature(3D),"
	MCT="Maximum Core Temperature(3D),"

	Access_trace="Access_trace,"
	Leakage_trace="Leakage_trace,"

	for (( c=0; c<$num_channels; c++ )) do
		for (( d=0; d<$layers; d++ )) do  
			matrix[$c,$d]=10000
			if [ $access_pattern_flag -eq 1 ]; then
				if [[ $c -eq 0 ]] || [[ $c -eq 3 ]] || [[ $c -eq 12 ]] || [[ $c -eq 15 ]]; then
					matrix[$c,$d]=12000
				fi
			fi

			if [ $access_pattern_flag -eq 2 ]; then
				if [[ $c -eq 1 ]] || [[ $c -eq 5 ]] || [[ $c -eq 9 ]] || [[ $c -eq 13 ]]; then
					matrix[$c,$d]=12000
				fi
			fi

			if [ $access_pattern_flag -eq 3 ]; then
				if [[ $c -eq 5 ]] || [[ $c -eq 6 ]] || [[ $c -eq 9 ]] || [[ $c -eq 10 ]]; then
					matrix[$c,$d]=9000
				fi
			fi

			if [ $access_pattern_flag -eq 4 ]; then
				if [[ $c -eq 3 ]] || [[ $c -eq 7 ]] || [[ $c -eq 11 ]] || [[ $c -eq 15 ]]; then
					matrix[$c,$d]=12000
				fi
			fi

		done
	done

	leakage_flag=()
	leakage_flag[0]=$1 	# 1: ON
	leakage_flag[1]=$2
	leakage_flag[2]=$3
	leakage_flag[3]=$4
	leakage_flag[4]=$5
	leakage_flag[5]=$6
	leakage_flag[6]=$7
	leakage_flag[7]=$8
	leakage_flag[8]=$9
	leakage_flag[9]=${10}
	leakage_flag[10]=${11}
	leakage_flag[11]=${12}
	leakage_flag[12]=${13}
	leakage_flag[13]=${14}
	leakage_flag[14]=${15}
	leakage_flag[15]=${16}


	for (( c=0; c<$num_channels; c++ )) do  
		if [ "${leakage_flag[$c]}" -ne "1" ]; then
			for (( d=0; d<$layers; d++ )) do  
				matrix[$c,$d]=0				
			done
		fi
	leakage=$leakage"${leakage_flag[$c]}"","
	done

	printf '%s' "@& 	1000	24459	0	24459	10000005d6180	6	" > tmp128_3D_d_"$t"
	for (( d=0; d<$layers; d++ )) do  
		for (( c=0; c<$num_channels; c++ )) do
			printf '%s' "${matrix[$c,$d]}," >> tmp128_3D_d_"$t"
		done
	done

	arr=()
	for (( c=0; c<$num_channels; c++ )) do
		for (( d=0; d<$layers; d++ )) do  
			arr[$c]=$((arr[$c] + matrix[$c,$d]))
		done
		arr[$c]=$((arr[$c] / $layers))
	done

	type_of_stack=$_hmc	
	i="d_"$t
	echo $i
	
	out_csv_file="random_try123.csv"

	if [ $sniper_simulation -eq 1 ]
	then
		/home/siddhulokesh/sniper/test/benchmarks/run-sniper -senergystats -sstattrace:core.energy-static  -sstattrace:core.energy-dynamic --benchmarks=parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1,parsec-$i-test-1 -c gainestown_my3D --no-roi > tmp128_3D_$i
		sniper_log="tmp128_3D_$i"
		cp sim.out sim128_3D_$i.out
	else
		sniper_log=$sniper_log_3D_prefix$i
	fi
	#LC Power Calculation

	for (( c=0; c<$num_channels; c++ ))
	do  
	LC_Power_number=`echo "scale=4;${arr[$c]}*0.00002493/1 + 0.0001" | bc -l`
	LC_Power=$LC_Power$LC_Power_number","

	done

#	LC_Power=$(echo 0.05*1 | bc)
	Logic_Core_power=$Logic_Core_power$LC_Power
#	./parser.py $sniper_log $banks $hotspot_run $leakage $type_of_stack $is_2_5d "0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05"
	./parser.py $sniper_log $banks $hotspot_run "$leakage" $type_of_stack $is_2_5d "$LC_Power"
	results_dir=$i/3D				# Results are stored here
	mkdir -p $results_dir

	if [ $type_of_stack -eq $_hmc ]
	then
		if [ $is_2_5d -eq 1 ]
		then
			cp hotspot/test_2_5_D$layers/HMC/4by4.steady $results_dir/4by4.steady
			cp hotspot/test_2_5_D$layers/HMC/gcc.grid.steady $results_dir/gcc.grid.steady
			cp 4by4.ttrace $results_dir/4by4.ttrace
		else
			cp hotspot/test$layers/HMC/4by4.steady $results_dir/4by4.steady
			cp hotspot/test$layers/HMC/gcc.grid.steady $results_dir/gcc.grid.steady
			cp 4by4.ttrace $results_dir/4by4.ttrace
		fi
	elif [ $type_of_stack -eq $_wio ]
	then
		if [ $is_2_5d -eq 1 ]
		then
			cp hotspot/test_2_5_D$layers/WIO/4by4.steady $results_dir/4by4.steady
			cp hotspot/test_2_5_D$layers/WIO/gcc.grid.steady $results_dir/gcc.grid.steady
			cp 4by4.ttrace $results_dir/4by4.ttrace
		else
			cp hotspot/test$layers/WIO/4by4.steady $results_dir/4by4.steady
			cp hotspot/test$layers/WIO/gcc.grid.steady $results_dir/gcc.grid.steady
			cp 4by4.ttrace $results_dir/4by4.ttrace
		fi
	fi
	
	cp 4by4.ptrace $results_dir/4by4.ptrace
#	cp sim128_3D_$i.out $results_dir/
	cp $sniper_log $results_dir/
	bench_list=$bench_list$i","

	#IPS Calculation
	# IPS=$IPS`grep "IPC" sim128_3D_$i.out | awk -v core_count=$num_cores '{t3=0;for(i = 3; i <= NF; i=i+2) {t3 +=$i;} }END{print 2.1*t3","}'`

	#Average Core Power Calculation
	sed '1d' 4by4.ptrace > 4by4.ptrace_temp 	
	if [ $type_of_stack -eq $_wio ]
	then
		awk '{for(i=17; i<=32; i++){sum[i]+=$i}} END {for(i=17; i<=32; i++){printf sum[i]/NR "\n"}}' 4by4.ptrace_temp > temp123
		Core_power=$Core_power`awk '{ total += $1; count++ } END { print total/count","}' temp123`
	fi	

	if [ $type_of_stack -eq $_hmc ]
	then
		if [ $is_2_5d -eq 1 ]
		then
			awk '{for(i=1; i<=16; i++){sum[i]+=$i}} END {for(i=1; i<=16; i++){printf sum[i]/NR "\n"}}' 4by4.ptrace_temp > temp123
			Core_power=$Core_power`awk '{ total += $1; count++ } END { print total/count","}' temp123`		
		fi		
	fi	

        #Average Bank Power Calculation
	sed '1d' 4by4.bptrace > 4by4.bptrace_temp 	
	awk '{for(i=1; i<=128; i++){sum[i]+=$i}} END {for(i=1; i<=128; i++){printf sum[i]/NR "\n"}}' 4by4.bptrace_temp > temp123
	Bank_power=$Bank_power`awk '{ total += $1; count++ } END { print total/count","}' temp123`

	#Max Bank Temperature Calculation		
	#Max_bank_temp=$Max_bank_temp`grep "_B2_2" $results_dir/4by4.steady | awk '{print $2-273","}'` #Vertical calculation
#	Max_bank_temp=$Max_bank_temp`grep -m 16 "_B[0-3]_[0-3]" $results_dir/4by4.steady | awk '{print $2-273","}'` #Bottom Layer calculation
	Max_bank_temp=$Max_bank_temp`grep -m 16 "_B[0-3]_[0-3]" $results_dir/4by4.steady | awk '{print $2-273","}'` #Bottom Layer calculation



	if [ $type_of_stack -eq $_hmc ]
	then
		if [ $is_2_5d -eq 1 ]
		then
			#Max LC Temperature Calculation		
			LC_temp=$LC_temp`grep "_LC" $results_dir/4by4.steady | awk '{print $2-273","}'`
			#Core Temperature Calculation		
			core_temp=$core_temp`grep "_C" $results_dir/4by4.steady | awk '{print $2-273","}'`
		fi		
	fi	

	MBT=$MBT`grep -m 16 "_B[0-3]_[0-3]" $results_dir/4by4.steady | awk -v max=0 '{if($2>max){max=$2}}END{print max-273}'`
	MLcT=$MLcT`grep "_LC" $results_dir/4by4.steady  | awk -v max=0 '{if($2>max){max=$2}}END{print max-273}'`
	MCT=$MCT`grep "_C" $results_dir/4by4.steady  | awk -v max=0 '{if($2>max){max=$2}}END{print max-273}'`

	echo $bench_list >> $out_csv_file
	echo $IPS >> $out_csv_file
	echo $Core_power >> $out_csv_file
	echo $Logic_Core_power >> $out_csv_file
	echo $Bank_power >> $out_csv_file
	echo $Max_bank_temp >> $out_csv_file
	echo $LC_temp >> $out_csv_file
	echo $core_temp >> $out_csv_file

	echo $MBT >> $out_csv_file
	echo $MLcT >> $out_csv_file
	echo $MCT >> $out_csv_file

	echo "Base Layer Rank Access from Channel 0 to 15"
	printf '%s\n' "${arr[0]},${arr[1]},${arr[2]},${arr[3]},${arr[4]},${arr[5]},${arr[6]},${arr[7]},${arr[8]},${arr[9]},${arr[10]},${arr[11]},${arr[12]},${arr[13]},${arr[14]},${arr[15]},"
	printf '%s' "$Access_trace" >> $out_csv_file
	for (( d=0; d<$layers; d++ )) do  
		for (( c=0; c<$num_channels; c++ )) do
			printf '%s' "${matrix[$c,$d]}," >> $out_csv_file
		done
	done

	printf '\n%s\n' "$Leakage_trace${leakage_flag[0]},${leakage_flag[1]},${leakage_flag[2]},${leakage_flag[3]},${leakage_flag[4]},${leakage_flag[5]},${leakage_flag[6]},${leakage_flag[7]},${leakage_flag[8]},${leakage_flag[9]},${leakage_flag[10]},${leakage_flag[11]},${leakage_flag[12]},${leakage_flag[13]},${leakage_flag[14]},${leakage_flag[15]}," >> $out_csv_file

	echo "Base Layer Rank Temperatures from Channel 0 to 15"
	echo $Max_bank_temp
	
done


# access_pattern_flag = 0
#Printed the temperature trace
#Base Layer Rank Access from Channel 0 to 15
#0,10000,10000,0,10000,0,0,10000,10000,0,0,10000,0,10000,10000,0,
#Base Layer Rank Temperatures from Channel 0 to 15
#62.42, 73.37, 73.37, 62.42, 73.37, 62.75, 62.75, 73.37, 73.37, 62.75, 62.75, 73.37, 62.42, 73.37, 73.37, 62.42,


#Printed the temperature trace
#Base Layer Rank Access from Channel 0 to 15
#10000,0,0,10000,0,10000,10000,0,0,10000,10000,0,10000,0,0,10000,
#Base Layer Rank Temperatures from Channel 0 to 15
#73.19, 62.59, 62.59, 73.19, 62.59, 73.62, 73.62, 62.59, 62.59, 73.62, 73.62, 62.59, 73.19, 62.59, 62.59, 73.19,
