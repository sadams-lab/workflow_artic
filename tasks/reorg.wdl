task BatchReorg {

    input {
    
        # Output files to be reorganized
        Array[Array[File]] artic_outputs
        Array[File] fastq_files

        # Output bucket info
        String output_bucket
        File gsutil_key

        String batch_id

        String docker_container
        Int threads
    }
  
    Int disk_size = length(artic_outputs) * 2 + 10
    Array[File] flat_outputs = flatten(artic_outputs)

    command <<<
        pip3 install pyopenssl requests

        gcloud auth activate-service-account --key-file ~{gsutil_key}

        for i in ~{sep=" " flat_outputs}
        do
            gsutil cp $i ~{output_bucket}/~{batch_id}/
        done

        for i in ~{sep=" " fastq_files}
        do
            gsutil cp $i ~{output_bucket}/~{batch_id}/fastq/
        done
    >>>

    output {

    }

    runtime {
        docker: docker_container
        cpu: threads
        #preemptible: preemptible_tries
        #zones: gcp_zones
        memory: 2 * threads + " GB"
        disks: "local-disk " + disk_size + " HDD"
    }
}