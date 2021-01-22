version 1.0

# Based on ARTIC pipeline described: https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html

import "" as basecall
import "" as filter

workflow ArticWorkflow {

    input {
        String flowcell
        String kit
        String run_name
        Array[File] fast5_files
        Array[String] barcodes

        Int guppy_threads = 2
        Int guppy_gpus = 1
        String guppy_ram = "8 GB"

        Int artic_threads = 4
        String artic_ram = "16 GB"
    }

    call basecall.Basecall as bc {
        input :
            flowcell = flowcell,
            kit = kit, 
            fast5_files = fast5_files,
            threads = guppy_threads, 
            gpus = guppy_gpus,
            ram = guppy_ram,
            barcodes = barcodes,
            run_name = run_name
    }

    scatter (barcode_fastq in bc.barcode_fastqs) {

        call filter.Filter as f {
            input : 
                run_name = run_name,
                barcode_fastq = barcode_fastq,
                threads = artic_threads,
                ram = artic_ram
        }
    }

    output {
        Array[File] f = f.fastq_filtered
    }
}
