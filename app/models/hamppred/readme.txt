The files with names matching hh*
in this directory currently are identical to the
files with the same name in ../hhpred.

As long as HAMP does not need a different version of a file,
it is deactivated (is not used).
To activate a file
a) rename it by replacing the prefix 'hh' with 'hamp_'.
This prefix is already used in hidden submit buttons in file ../../views/hamppred/results.rhtml
b) edit ../../../config/hamppred_jobs.yml by adding an appropriate job configuration,
using hhpred_jobs.yml as a template.
