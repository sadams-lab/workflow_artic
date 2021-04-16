version 1.0

# Based on ARTIC pipeline described: https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html

workflow ArticWorkflow {

    input {

        String batch_id
        File fast5_file_list

        Array[String] sample_ids
        Array[String] barcodes = ["barcode01", "barcode02", "barcode03", "barcode04", 
                                  "barcode05", "barcode06", "barcode07", "barcode08",
                                  "barcode09", "barcode10", "barcode11", "barcode12"]
        
        File gsutil_key

        String output_bucket

        Int base_threads = 2

        Int guppy_threads = 2
        Int guppy_gpus = 1
        String guppy_ram = "8 GB"

        Int artic_threads = 4
        String artic_ram = "16 GB"

        String reorg_docker = "gcr.io/google.com/cloudsdktool/cloud-sdk"

    }

    Array[File] fast5_files = read_lines(fast5_file_list)

    call Basecall as bc {
        input :
            fast5_files = fast5_files,
            keep_barcodes = barcodes,
            threads = guppy_threads, 
            gpus = guppy_gpus,
            ram = guppy_ram,
    }

    Array[Pair[File, String]] barcode_ids = zip(bc.barcode_fastqs, sample_ids)

    scatter (bc_id in barcode_ids) {

        call Filter as f {
            input : 
                sample_id = bc_id.right,
                barcode_fastq = bc_id.left,
                threads = artic_threads,
                ram = artic_ram
        }

        call ArticMinion {
            input : 
                sample_id = bc_id.right,
                fastq_file = f.fastq_filtered,
                fast5_files = fast5_files,
                sequencing_summary = bc.sequencing_summary,
                threads = artic_threads,
                ram = artic_ram
        }
    }

    call BatchReorg {
        input : 
            artic_outputs = ArticMinion.outputs,
            output_bucket = output_bucket,
            gsutil_key = gsutil_key,
            batch_id = batch_id,
            docker_container = reorg_docker,
            threads = base_threads
    }

    output {
    }
}