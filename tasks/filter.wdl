task Filter {

    input {
        String run_name
        File barcode_fastq

        Int threads
        String ram
    }

    Int disk_size = ceil(size(barcode_fastq, "GB")) * 10 + 10

	command <<<

        source activate artic-ncov2019
        
        mkdir fastq

        tar xzf ~{barcode_fastq} -C fastq/

        BARCODE=~{barcode_fastq}
        BARCODE=${BARCODE%.tar.gz}
        BARCODE=${BARCODE##*/}
        
        artic guppyplex \
            --min-length 200 \
            --max-length 800 \
            --directory fastq/$BARCODE \
            --prefix ~{run_name}
        
        mv *.fastq $BARCODE.filtered.fastq
    >>>

    output {
        File fastq_filtered = glob("*.fastq")[0]
    }

    runtime {
        cpu: threads
        memory: ram
        docker: "adamslab/artic"
        disks: "local-disk " + disk_size + " HDD"
    }
	
}

