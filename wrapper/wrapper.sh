ARGS=" ${index} ${alg} ${h5dump} ${in_name} ${kmer} ${mu} ${ouput} ${bias} ${bs} ${seed} ${plaintext} ${single} ${frs} ${rfs} ${frag_len} ${sd} ${pseudobam} ${umi}"
INPUTS=" ${fasta}, ${fasta_index}, ${fastq}, ${batch}"
echo $ARGS

INDEX=${index}
FASTA_INDEX=${fasta_index}
IN_NAME=${in_name}
H5DUMP=${h5dump}
echo ${output}

CMDLINEARG=""
if [ -z "${INDEX}" ]
  then
    if [ -z "${FASTA_INDEX}" ]
      then
        echo "A FASTA index is required. Run 'index' or provide a File"
        exit 1;
    else
      ${IN_NAME}=${FASTA_INDEX}
    fi
else
  CMDLINEARG+="kallisto ${INDEX} ${IN_NAME} ${kmer} ${mu} ${fasta}; "
fi
CMDLINEARG+="kallisto ${alg} ${IN_NAME} ${output} ${single} ${frag_len} ${sd} ${pseudobam} "
if [ "${alg}" == "quant" ]
  then
    CMDLINEARG+="${bias} ${bs} ${seed} ${plaintext} ${frs} ${rfs} "
else
  CMDLINEARG+="${umi} "
fi
CMDLINEARG+="${fastq}; "
if [ -n "${H5DUMP}" ]
  then
    if [ "${alg}" != "quant" ]
      then
        echo "h5dump may be used just after 'quant' mode"
        exit 1;
    else
      echo "WARNING: h5dump will overwrite .tsv file"
      CMDLINEARG+="kallisto ${H5DUMP} ${output} ${output}/abundance.h5;"
    fi
fi

echo ${CMDLINEARG};

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/kallisto:v0.43.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments				= ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTS} launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = ${output} >> lib/condorSubmitEdit.htc
cat lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

exit 0
