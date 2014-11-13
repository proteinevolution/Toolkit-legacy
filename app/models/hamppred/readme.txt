Following files probably are referenced, but only available in directory ../hhpred:
hh3d_querytempl_action.rb
hh3d_querytempl_job.rb
hh3d_templ_action.rb
hh3d_templ_job.rb
hhmakemodel_action.rb
hhmakemodel_forward_action.rb
hhmakemodel_job.rb
hhmergeali_action.rb
hhmergeali_job.rb

As long as HAMP does not need a different version of a file,
it is deactivated (is not used).
To activate a file
a) rename it by replacing the prefix 'hh' with 'hamp_'.
This prefix is already used in hidden submit buttons in file ../../views/hamppred/results.rhtml
b) edit ../../../config/hamppred_jobs.yml by adding an appropriate job configuration,
using hhpred_jobs.yml as a template.
