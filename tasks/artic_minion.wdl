task ArticMinion {

    input {
        String sample_id

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
            --normalise 0 \
            --threads ~{threads} \
            --scheme-directory /artic-ncov2019/primer_schemes \
            --read-file ~{fastq_file} \
            --fast5-directory fast5 \
            --sequencing-summary ~{sequencing_summary} \
            nCoV-2019/V3 \
            ~{sample_id}
        
        mkdir results
        mv ~{sample_id}* results/
    >>>

    output {

        Array[File] outputs = glob("results/*")
    }

    runtime {
        cpu: threads
        memory: ram
        docker: "adamslab/artic"
        disks: "local-disk " + disk_size + " HDD"
    }
	
}

