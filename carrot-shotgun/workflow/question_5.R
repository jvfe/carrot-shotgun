
fasta_file <- "SRR31030799_results/SRR31030799_prodigal_prediction/SRR31030799_proteins.faa"


lines <- readLines(fasta_file)

header_indices <- grep("^>", lines)

protein_count <- length(header_indices)

protein_lengths <- numeric(protein_count)



for (i in 1:protein_count) {
  # Determine the start line of the sequence for the current protein.
  start_line <- header_indices[i] + 1
  
  # Determine the end line of the sequence. This is either the line just
  # before the *next* header or the very last line of the file if it's
  # the last protein.
  end_line <- if (i < protein_count) {
    header_indices[i + 1] - 1
  } else {
    length(lines)
  }
  
  if (start_line > end_line) {
    protein_lengths[i] <- 0
  } else {
    # Extract all lines belonging to the current protein's sequence.
    sequence_lines <- lines[start_line:end_line]
    
    # Collapse the lines into a single, continuous string.
    full_sequence <- paste(sequence_lines, collapse = "")
    
    # Calculate the number of characters (amino acids) and store it.
    protein_lengths[i] <- nchar(full_sequence)
  }
}


if (protein_count > 0) {
  min_length <- min(protein_lengths)
  max_length <- max(protein_lengths)
  avg_length <- mean(protein_lengths)

  cat("--- Protein FASTA Statistics ---\n")
  cat("File:", basename(fasta_file), "\n\n")
  cat("Total Protein Count:", protein_count, "\n")
  cat("Minimum Length:", min_length, "aa\n")
  cat("Maximum Length:", max_length, "aa\n")
  cat("Average Length:", round(avg_length, 2), "aa\n")
  
} else {
  cat("No protein sequences were found in the file.\n")
}
