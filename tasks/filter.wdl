version 1.0

task Filter {

    input {
        String run_name
        File barcode_fastq

        Int threads
        String ram
    }

    Int disk_size = ceil(size(barcode_fastq[1], "GB")) * 10 + 10

	command {
        mkdir ~{barcode_fastq[0]}

        tar czf ~{barcode_fastq[1]} -C ~{barcode_fastq[0]}/

        artic guppyplex \
            --min-length 400 \
            --max-length 700 \
            --directory ~{barcode_fastq[0]} \
            --prefix ~{run_name}
    }

    output {
        File fastq_filtered = "~{run_name}_~{barcode_fastq[0]}.fastq"
    }

    runtime {
        cpu: threads
        memory: ram
        docker: "adamslab/artic"
        disks: "local-disk " + disk_size + " HDD"
    }
	
}

