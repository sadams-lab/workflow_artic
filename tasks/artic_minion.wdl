task ArticMinion {

    input {
        String run_name
        File fastq_file
        File sequencing_summary
        Array[File] fast5_files

        Int threads
        String ram
    }

    Int disk_size = ceil(size(fastq_file, "GB")) * 5 + 10

	command <<<
        source activate artic-ncov2019
        
        mkdir fast5

        for f in ~{sep = ' ' fast5_files} ; 
        do
            mv $f fast5/
        done

        BARCODE=~{fastq_file}
        BARCODE=${BARCODE%.fastq}
        BARCODE=${BARCODE##*/}

        artic minion \
            --normalise 200 \
            --threads ~{threads} \
            --scheme-directory /artic-ncov2019/primer_schemes \
            --read-file ~{fastq_file} \
            --fast5-directory fast5 \
            --sequencing-summary ~{sequencing_summary} \
            nCoV-2019/V3 \
            $BARCODE
    >>>

    output {

        Array[File] outputs = glob("barcode*") # - BAM file for visualisation after primer-binding site trimming
    }

    runtime {
        cpu: threads
        memory: ram
        docker: "adamslab/artic"
        disks: "local-disk " + disk_size + " HDD"
    }
	
}

