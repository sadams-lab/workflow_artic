version 1.0

# Based on ARTIC pipeline described: https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html

workflow ArticWorkflow {

    input {
        String run_name
        String batch_directory
        File fast5_file_list

        Array[String] barcodes = ["barcode01", "barcode02", "barcode03", "barcode04", 
                                  "barcode05", "barcode06", "barcode07", "barcode08",
                                  "barcode09", "barcode10", "barcode11", "barcode12"]

        Int guppy_threads = 2
        Int guppy_gpus = 1
        String guppy_ram = "8 GB"

        Int artic_threads = 4
        String artic_ram = "16 GB"
    }

    Array[File] fast5_files = read_lines(fast5_file_list)

    call Basecall as bc {
        input :
            fast5_files = fast5_files,
            keep_barcodes = barcodes,
            threads = guppy_threads, 
            gpus = guppy_gpus,
            ram = guppy_ram,
            run_name = run_name
    }

    scatter (barcode_fastq in bc.barcode_fastqs) {

        call Filter as f {
            input : 
                run_name = run_name,
                barcode_fastq = barcode_fastq,
                threads = artic_threads,
                ram = artic_ram
        }

        call ArticMinion {
            input : 
                run_name = run_name,
                fastq_file = f.fastq_filtered,
                fast5_files = fast5_files,
                sequencing_summary = bc.sequencing_summary,
                threads = artic_threads,
                ram = artic_ram
        }
    }

    output {
        Array[Array[File]] all_outputs = ArticMinion.outputs
    }
}