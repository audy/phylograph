# A SIMPLE INTERFACE FOR CDHIT

class Cluster
  def self.compute_clusters(similarity, filename)  
    output = "#{filename}_out"
    # Compute clusters    
    run_cdhit filename, output, similarity
    
    # Parse CDHIT Output
    parse_cdhit output
    # Return results
  end
  
  def self.run_cdhit(input, output, similarity)
    res = system "./lib/cd-hit-est \
      -i #{input} \
      -o #{output} \
      -c 0.#{similarity} \
      > /dev/null"
    unless res
      $stderr.puts "cdhit failed"
      quit -1
    end
  end
  
  def self.parse_cdhit(output)
    clusters = Hash.new
    clusters[:counts] = Hash.new 0
    clusters[:reps] = Hash.new

    # Number of sequences per cluster
    handle = File.open "#{output}.clstr"
    i, c = 0, 0
    handle.each do |line|
      if line[0] == '>'
        if c > 0
          clusters[:counts][i] = c
          c = 0
          i += 1
        end
      else
        c += 1
      end
      line.split(/\t/)
      clusters[:counts][i] += 1
    end

    # Representative for each cluster
    # They're in order of cluster number
    handle = File.open "#{output}"
    cluster = -1
    handle.each_with_index do |line|
      if line[0] == '>'
        cluster += 1
      else
        clusters[:reps][cluster] = line[0..-2]
      end
    end
    
    # Make sure they have the same keys
    raise "Something went wrong with CD-HIT parsing" \
      unless (clusters[:counts].keys - clusters[:reps].keys) == []
        
    clusters
  end
  
end