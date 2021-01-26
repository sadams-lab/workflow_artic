task Basecall {
    
    input {
        Array[File] fast5_files
        String run_name
        Array[String] keep_barcodes

        Int threads
        Int gpus
        String ram
    }

    Int disk_size = ceil(size(fast5_files[0], "GB")) * length(fast5_files) + 25

    command <<<
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
            --compress_fastq \
            -x auto

        guppy_barcoder \
            -s fastq_demux \
            --arrangements_files "barcode_arrs_nb12.cfg" \
            -i fastq
        
        cd fastq_demux
        for dir in ~{sep=" " keep_barcodes}
        do
            tar czf $dir.tar.gz $dir
        done
    >>>

    output {
        Array[File] barcode_fastqs = glob("fastq_demux/*.tar.gz")
        File sequencing_summary = "fastq/sequencing_summary.txt"
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
