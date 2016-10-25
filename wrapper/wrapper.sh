#!/bin/bash

rmthis=`ls`
echo ${rmthis}

ARGSU=" ${index} ${alg} ${h5dump} ${in_name} ${kmer} ${mu} --output-dir output ${bias} ${bs} ${seed} ${plaintext} ${single} ${frs} ${rfs} ${frag_len} ${sd} ${pseudobam} ${umi}"
FASTAU=`echo ${fasta} | sed -e 's/ /, /g'`
FASTQU=`echo ${fastq} | sed -e 's/ /, /g'`
INPUTSU="${FASTAU}, ${fasta_index}, ${FASTQU}"
echo "FASTQU is " "${FASTQU}"
echo "fastq is " "${fastq}"
echo "arguments are "${ARGSU}
echo "inputs are "${INPUTSU}

INDEXU="${index}"
FASTA_INDEXU="${fasta_index}"
IN_NAMEU="${in_name}"
H5DUMPU="${h5dump}"
SINGLEU="${single}"
FRAG_LENU="${frag_len}"
SDU="${sd}"
#echo ${output}


if [ -n "${SINGLEU}" ]
  then
    if [ -z "${FRAG_LENU}" ] || [ -z "${SDU}" ]
      then
        echo "for  single read fragment length and standard deviation must be provided"
        exit 1;
    fi
fi

CMDLINEARG=""
#echo "starting if part";
#echo ${index};
if [ -z "${INDEXU}" ]
  then
    #echo 1;
    if [ -z "${FASTA_INDEXU}" ]
      then
        #echo 2;
        echo "A FASTA index is required. Run 'index' or provide a File"
        exit 1;
    else
      #echo 2bis;
      ${IN_NAMEU}=${FASTA_INDEXU}
    fi
else
  #echo 1bis;
  CMDLINEARG+="kallisto ${INDEXU} ${IN_NAMEU} ${kmer} ${mu} ${fasta}; "
fi
CMDLINEARG+="kallisto ${alg} ${IN_NAMEU} --output-dir output ${single} ${frag_len} ${sd} ${pseudobam} "
if [ "${alg}" == "quant" ]
  then
    #echo 3;
    CMDLINEARG+="${bias} ${bs} ${seed} ${plaintext} ${frs} ${rfs} "
else
  #echo 3bis;
CMDLINEARG+="${umi} "
fi
CMDLINEARG+="${fastq}; "
#echo ${H5DUMP}
if [ -n "${H5DUMPU}" ]
  then
    #echo 4;
    if [ "${alg}" != "quant" ]
      then
        #echo 5;
        echo "h5dump may be used just after 'quant' mode"
        exit 1;
    else
      #echo 5bis;
      echo "WARNING: h5dump will overwrite .tsv file"
      CMDLINEARG+="kallisto ${H5DUMPU} --output-dir output output/abundance.h5 "
    fi
fi

#echo ciao;
echo ${CMDLINEARG};
chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/kallisto:v0.43.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/rosysnake/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

exit 0
