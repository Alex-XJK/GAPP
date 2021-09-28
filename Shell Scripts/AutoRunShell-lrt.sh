#!/bin/bash

# Variables setting
rootdir="./gapp_disk2"
shellroot="./gapp_disk2/user1/code"

# Start up variables
current_time=$(date "+%Y%m%d-%H%M%S")
sta_total=`date +%s`
isSmallFile="0"

# Directory variables
logfilename="shell_output_${current_time}.txt"
log=$rootdir/$logfilename

# Setup name pipe
# mkfifo -m 777 $rootdir/npipe

# Function block
shellVersion () {
    echo -e "\033[35m"
    echo "AutoRunShell >> @param -l Load all module every time." | tee -a ${log}
    echo "AutoRunShell >> @param -r Record this console log (may not work)." | tee -a ${log}
    echo "AutoRunShell >> @param -t Do the timing." | tee -a ${log}
    echo "AutoRunShell >> @version 4.3" | tee -a ${log}
    echo "AutoRunShell >> @since Sept. 9, 2021" | tee -a ${log}
    echo -e "\033[0m"
}

loadAll () {
    echo -e "\033[33mAutoRunShell >> Load all is now be called!" | tee -a ${log}
    module load gatk/3.8-0-java-1.8.0_144
    module load annovar/2019oct24-perl-5.30.2
    echo -e "\033[0m"
}

printDir () {
    echo -e "\033[36mAutoRunShell >> Current Directory" | tee -a ${log}
    pwd | tee -a ${log}
    echo -e "\033[0m"   
}

blankLine () {
    echo " "
    echo " "
    echo " ========== ~\(≧▽≦)/~ ========== "
    echo " "
    echo " "
}

systemDirInfo () {
    echo -e "\033[36m"
    echo "AutoRunShell >> Current user: ${USER} (id: ${UID})" | tee -a ${log}
    echo "AutoRunShell >> Generate Scripts shell is located at: ${rootdir}" | tee -a ${log}
    echo "AutoRunShell >> All the remaining work shell are located at: ${shellroot}" | tee -a ${log}
    echo "AutoRunShell >> Log will be write to console as well as file: ${log}" | tee -a ${log}
    echo "AutoRunShell >> CPU info:" | tee -a ${log}
    lsb_release -a | tee -a ${log}
    echo -e "\033[0m"
}

fsizeJudge () {
    let threshold=3500000000

    let tfsize=$(ls -l $1 | awk '{print $5}')
    if [ "$tfsize" -gt "$threshold" ]; 
    then
        echo -e "\033[32m"
        echo "AutoRunShell >> fsizeJudge >> Now checking file $1" | tee -a ${log}
        echo -e  "AutoRunShell >> fsizeJudge >> \t\t $(ls -l $1)"
        echo "AutoRunShell >> fsizeJudge >> GOOD DATA SIZE: Your filesize is $tfsize greater than threshold ($threshold). Go ahead and have a good day!" | tee -a ${log}
        echo -e "\033[0m"
    else
        echo -e "\033[31m"
        echo "AutoRunShell >> fsizeJudge >> Now checking file $1" | tee -a ${log}
        echo -e "AutoRunShell >> fsizeJudge >> \t\t $(ls -l $1)"
        echo "AutoRunShell >> fsizeJudge >> SMALL DATA WARN: Your filesize is $tfsize, which is smaller than the threshold ($threshold). Error may occur during the analysing process, consider disabling the filtering function!" | tee -a ${log}
        isSmallFile="1"
	    # echo "$isSmallFile" > $rootdir/npipe
       	# read -p "Do you want to continue anyway [y/n]:" concho
        # case $concho in
        # y) 
        #     echo "Sure";;
        # n)
        #     exit;;
        # *)
        #     echo "error choice";;
        # esac
        echo -e "\033[0m"
    fi
}

# Export the functions to global so that child process can use them.
export -f loadAll fsizeJudge 

# Welcome
echo -e "\033[35mAutoRunShell >> Welcome!\033[0m" | tee -a ${log}
shellVersion

# Display system time
echo -e "\033[36mAutoRunShell >> System Time ${current_time}\033[0m" | tee -a ${log}

# Display current path
printDir

# Display files' locations
systemDirInfo

blankLine

# a00-Generate Scripts
echo -e "\033[33mAutoRunShell >> generate_script.sh\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
sh $rootdir/generate_script.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> generate_script ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# Display current path
printDir

blankLine

# read isSmallFile < $rootdir/npipe
echo "DEBUG >> is_small? $isSmallFile"
# rm $rootdir/npipe

# a01-filterfq
echo -e "\033[33mAutoRunShell >> a01\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
if [ "$isSmallFile"x == "0"x ];
then
    loadAll
    sh $shellroot/a01-filterfq.sh | tee -a ${log}
else
    echo -e "\033[31mAutoRunShell >> a01-filterfq is skipped because of the small file size!\033[0m" | tee -a ${log}
fi
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a01-filterfq ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a02-mem
echo -e "\033[33mAutoRunShell >> a02\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a02-mem.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a02-mem ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a03-rmclean
echo -e "\033[33mAutoRunShell >> a03\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a03-rmclean.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a03-rmclean ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a04-sort
echo -e "\033[33mAutoRunShell >> a04\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a04-sort.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a04-sort ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a05-rmfixmate
echo -e "\033[33mAutoRunShell >> a05\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a05-rmfixmate.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a05-rmfixmate ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a06-markdup
echo -e "\033[33mAutoRunShell >> a06\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a06-markdup.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a06-markdup ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a07-bamindex
echo -e "\033[33mAutoRunShell >> a07\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a07-bamindex.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a07-bamindex ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a08-rmsort
echo -e "\033[33mAutoRunShell >> a08\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a08-rmsort.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a08-rmsort ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a09-realignercreator
echo -e "\033[33mAutoRunShell >> a09\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a09-realignercreator.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a09-realignercreator ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a10-realn
echo -e "\033[33mAutoRunShell >> a10\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a10-realn.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a10-realn ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a11-baserecal
echo -e "\033[33mAutoRunShell >> a11\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a11-baserecal.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a11-baserecal ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a12-printreads
echo -e "\033[33mAutoRunShell >> a12\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a12-printreads.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a12-printreads ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a13-hc
echo -e "\033[33mAutoRunShell >> a13\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a13-hc.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a13-hc ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a14-rmbaserecal
echo -e "\033[33mAutoRunShell >> a14\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a14-rmbaserecal.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a14-rmbaserecal ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a15-rmrealn
echo -e "\033[33mAutoRunShell >> a15\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a15-rmrealn.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a15-rmrealn ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a16-concat
echo -e "\033[33mAutoRunShell >> a16\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a16-concat.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a16-concat ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a17-vqsrsnp
echo -e "\033[33mAutoRunShell >> a17\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a17-vqsrsnp.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a17-vqsrsnp ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a18-applysnp
echo -e "\033[33mAutoRunShell >> a18\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a18-applysnp.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a18-applysnp ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a19-vqsrindel
echo -e "\033[33mAutoRunShell >> a19\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a19-vqsrindel.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a19-vqsrindel ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a20-applyindel
echo -e "\033[33mAutoRunShell >> a20\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a20-applyindel.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a20-applyindel ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# a21-annovar-vcf
echo -e "\033[33mAutoRunShell >> a21\033[0m" | tee -a ${log}
sta_tmp=`date +%s`
loadAll
sh $shellroot/a21-annovar-vcf.sh | tee -a ${log}
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo -e "\033[36mAutoRunShell >> a21-annovar-vcf ~ ${dif_tmp} seconds\033[0m" | tee -a ${log}

blankLine

# Finishing up
echo -e "\033[35mAutoRunShell >> Finished\033[0m" | tee -a ${log}

blankLine

end_total=`date +%s`
let dif_total=($end_total - $sta_total)
echo -e "\033[36mAutoRunShell >> The whole program spend ${dif_total} seconds to run\033[0m" | tee -a ${log}

blankLine

# Display finished system time
finished_time=$(date "+%Y%m%d-%H%M%S")
echo -e "\033[36mAutoRunShell >> System Time ${finished_time}\033[0m" | tee -a ${log}

# Bye
echo -e "\033[35mAutoRunShell >> Bye~\033[0m" | tee -a ${log}
