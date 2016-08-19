#!/bin/bash

rmthis=`ls`
echo ${rmthis}

ARGS=" ${index} ${alg} ${h5dump} ${in_name} ${kmer} ${mu} --output-dir . ${bias} ${bs} ${seed} ${plaintext} ${single} ${frs} ${rfs} ${frag_len} ${sd} ${pseudobam} ${umi}"
#echo $ARGS

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

#echo ciao;
echo ${CMDLINEARG};
echo running docker now

docker run -v `pwd`:/data cyverseuk/kallisto:v0.43.0 /bin/bash -c "${CMDLINEARG}";

rmthis=`echo ${rmthis} | sed s/.*\.out// -`
rmthis=`echo ${rmthis} | sed s/.*\.err// -`
rm --verbose ${rmthis}

exit 0

