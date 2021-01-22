version 1.0

task BaseCall {
    
    input {
        String flowcell
        String kit
        Array[File] fast5_files
        String run_name
        Array[String] barcodes

        Int threads
        Int gpus
        String ram
    }

    Int disk_size = ceil(size(fast5_files[0], "GB")) * length(fast5_files) + 25

    command {
        mkdir fastq
        mkdir fast5
        mkdir fastq_demux

        for f in ~{sep = ' ' fast5_files} ; 
        do
            mv $f fast5/
        done

        # Basecall
        guppy_basecaller \
            -c dna_r9.4.1_450bps_hac.cfg \
            --input_path fast5 \
            --save_path fastq \
            --flowcell ~{flowcell} \
            --kit ~{kit} \
            --device auto \
            --compress_fastq \
            -s ~{run_name} \
            -x auto \
            -r

        guppy_barcoder \
            --require_barcodes_both_ends \
            -s fastq_demux \
            --arrangements_files "barcode_arrs_nb12.cfg" \
            -i ~{run_name}
        
        for b in ~{sep = ' ' barcodes}
        do
            tar czf $b.tar.gz fastq_demux/$b
            echo $b
        done
    }

    Array[File] barcode_fastqs = glob("*.tar.gz")
    Array[String] barcode_ids = read_lines(stdout())

    output {
        Array[Pair] barcode_fastqs = zip(barcode_ids, barcode_fastqs)
    }

    runtime {
        cpu: threads
        bootDiskSizeGb: 25
        memory: ram
        docker: "adamslab/guppy"
        disks: "local-disk " + disk_size + " HDD"
        gpuType: "nvidia-tesla-p100"
        gpuCount: gpus
        zones: ["us-central1-c", "us-central1-f", "us-east1-b", "us-east1-c"]
    }
    
}

