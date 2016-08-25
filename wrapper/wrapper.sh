ARGS=" ${index} ${alg} ${h5dump} ${in_name} ${kmer} ${mu} --output-dir output ${bias} ${bs} ${seed} ${plaintext} ${single} ${frs} ${rfs} ${frag_len} ${sd} ${pseudobam} ${umi}"
FASTA=`echo ${fasta} | sed -e 's/ /, /g'`
FASTQ=`echo ${fastq} | sed -e 's/ /, /g'`
INPUTS="${FASTA}, ${fasta_index}, ${FASTQ}"
echo ${ARGS}
echo ${INPUTS}

INDEX="${index}"
FASTA_INDEX="${fasta_index}"
IN_NAME="${in_name}"
H5DUMP="${h5dump}"
SINGLE="${single}"
FRAG_LEN="${frag_len}"
SD="${sd}"
#echo ${output}

if [ -n "${SINGLE}" ]
  then
    if [ -z "${FRAG_LEN}" ] || [ -z "${SD}" ]
      then
        echo "for  single read fragment length and standard deviation must be provided"
        exit 1;
    fi
fi

CMDLINEARG=""
#echo "starting if part";
#echo ${index};
if [ -z "${INDEX}" ]
  then
    #echo 1;
    if [ -z "${FASTA_INDEX}" ]
      then
        #echo 2;
        echo "A FASTA index is required. Run 'index' or provide a File"
        exit 1;
    else
      #echo 2bis;
      ${IN_NAME}=${FASTA_INDEX}
    fi
else
  #echo 1bis;
  CMDLINEARG+="kallisto ${INDEX} ${IN_NAME} ${kmer} ${mu} ${fasta}; "
fi
CMDLINEARG+="kallisto ${alg} ${IN_NAME} --output-dir . ${single} ${frag_len} ${sd} ${pseudobam} "
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
if [ -n "${H5DUMP}" ]
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
      CMDLINEARG+="kallisto ${H5DUMP} --output-dir . output/abundance.h5 "
    fi
fi

echo "${CMDLINEARG}";

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/kallisto:v0.43.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments				= ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTS} launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

exit 0
