class HhmergealiAction < Action
  
  attr_accessor :hits

  validates_checkboxes(:hits, {:on => :create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)

    seqs   = params["hits"]

    @commands = []

    # Remove redundant hits
    @seqs = seqs.split(' ')
    @seqs = @seqs.uniq.join(' ')

    # @dirs = Dir.glob(File.join(DATABASES, 'hhpred/new_dbs/*')).join(' ');

    pjob = job.parent
    @dbs = pjob.params_main_action['hhpred_dbs'].nil? ? "" : pjob.params_main_action['hhpred_dbs']
    if @dbs.kind_of?(Array) then @dbs = @dbs.join(' ') end
    @genomes_dbs = pjob.params_main_action['genomes_hhpred_dbs'].nil? ? "" : pjob.params_main_action['genomes_hhpred_dbs']
    if @genomes_dbs.kind_of?(Array) then @genomes_dbs = @genomes_dbs.join(' ') end

    process_databases

    @dirs = @dbs + " " + @genomes_dbs

    logger.debug "Dirs: #{@dirs}"

  end

  def process_databases

    # Expand cdd and interpro as list of member databases
    if (@dbs =~ /cdd_/)
      ['pfam_*', 'smart_*', 'KOG_*', 'COG_*', 'cd_*'].each do |db|
        db_path = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', db))[0]
        if (!db_path.nil?)
          @dbs += " " + db_path
        end
      end
      @dbs.gsub!(/\s*\S+\/cdd_\S+\s+/, ' ')
    end
    if (@dbs =~ /interpro_/)
      ['pfamA_*', 'smart_*', 'panther_*', 'tigrfam_*', 'pirsf_*', 'supfam_*', 'CATH_*'].each do |db|
        db_path = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', db))[0]
        if (!db_path.nil?)
          @dbs += " " + db_path
        end
      end
      @dbs.gsub!(/\s*\S+\/interpro_\S+\s+/, ' ')
    end

    # Replace pdb70_* with new version of pdb
    newpdb = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pdb70_*'))[0]
    @dbs.gsub!(/\S*pdb70_\S+/, newpdb)

  end

  def before_perform_on_forward

    pjob = job.parent
    @parent_basename = File.join(pjob.job_dir, pjob.jobid)
    @parent_jobdir = pjob.job_dir

  end

  def perform
    params_dump

    @commands << "source #{SETENV}"
    # Make FASTA alignment from query and selected templates (from hhr file). -N: use $parentId as query name
    @commands << "hhmakemodel.pl -v 2 -N -m #{@seqs} -i #{@parent_basename}.hhr -fas #{@basename}.qt.fas -q #{@parent_basename}.a3m";

    # Merge all alignments whose sequences are given in $basename.qt.fas
    @commands << "mergeali.pl #{@basename}.qt.fas #{@basename}.qt.a3m -d #{@parent_jobdir} #{@dirs} -diff 100 -mark";

    @commands << "hhfilter -diff 100 -i #{@basename}.qt.a3m -o #{@basename}.qt.reduced.a3m";

    @commands << "reformat.pl a3m fas -r -noss #{@basename}.qt.reduced.a3m #{@basename}.qt.reduced.fas";
    @commands << "reformat.pl a3m fas -noss #{@basename}.qt.a3m #{@basename}.qt.fas";

    @commands << "gzip -c #{@basename}.qt.fas >  #{@basename}.qt.fas.gz ";
    @commands << "gzip -c #{@basename}.qt.reduced.fas >  #{@basename}.qt.reduced.fas.gz ";
    @commands << "source #{UNSETENV}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end
end
