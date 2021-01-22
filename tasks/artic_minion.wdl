version 1.0

task ArticMinion {

    input {
        String run_name
        String barcode
        Array[File] fastq_files
        Array[File] fast5_files

        Int threads
        String ram
    }

    Int disk_size = ceil(size(fastq_files[0], "GB")) * length(fastq_files) + 10

	command {
        mkdir ~{sample_name}

        for f in ~{sep = ' ' fastq_files} 
        do
            mv $f ~{sample_name}/
        done

        artic guppyplex \
            --min-length 400 \
            --max-length 700 \
            --directory ~{sample_name} \
            --prefix ~{run_name}
    }

    output {
        File fastq_filtered = "~{run_name}_~{sample_name}.fastq"
    }

    runtime {
        cpu: threads
        memory: ram
        docker: "adamslab/artic"
        disks: "local-disk " + disk_size + " HDD"
    }
	
}

