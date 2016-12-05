function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  for(i = 0; i < (blocks*number); i++) {
    $(clustalw_form).elements["hits[]"][i].checked = false;
  }
  calculate_forwarding();
}
function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  for(i = 0; i < (blocks*number); i++) {
    $(clustalw_form).elements["hits[]"][i].checked = true;
  }
  calculate_forwarding();
}
function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  var first = 10;
  for(b = 0; b < blocks; b++) {
    for (i = 0; i < number; i++) {
      if (i < first) {
        $(clustalw_form).elements["hits[]"][(b*number+i)].checked = true;
      } else {
        $(clustalw_form).elements["hits[]"][(b*number+i)].checked = false;      
      }
    }  
  }
  calculate_forwarding();
}

function change(num, block)
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  var mode = $(clustalw_form).elements["hits[]"][(block * number)+num].checked;
  for (b = 0; b < (blocks); b++) {
    $(clustalw_form).elements["hits[]"][(b * number)+num].checked = mode;
  }
}

function pasteExample()
{
  document.getElementById('sequence_input').value = ">1a0i241-349\nPENEADGIIQGLVWGTKGLANEGKVIGFEVLLESGRLVNATNISRALMDEFTETVKEATLSQWGFFDACTINPYDGWACQISYMEETPDGSLRHPSFVMFR\n>YP_91898#2 DNA ligase [Yersinia phage Berlin]   CAJ\nPECEADGIIQSVNWGTPGLSNEGLVIGFNVLLETGRHVAANNISQTLMEELTANAKEHGEDYYNGWACQVAYMEETSDGSLRHPSFVMFR\n>YP_338096#3 ligase [Enterobacteria phage K1F]   AAZ7297\nPSEEADGHVVRPVWGTEGLANEGMVIGFDVMLENGMEVSATNISRALMSEFTENVKSDPDYYKGWACQITYMEETPDGSLRHPSFDQWR\n>NP_523305#4 DNA ligase [Bacteriophage T3]   P07717|DNLI_B\nPECEADGIIQGVNWGTEGLANEGKVIGFSVLLETGRLVDANNISRALMDEFTSNVKAHGEDFYNGWACQVNYMEATPDGSLRHPSFEKFR\n>CAK24995#5 putative DNA ligase [Bacteriophage LKA1]   E=4e-40 s/c=1.7\nPGFEADGTVIDYVWGDPDKANANKIVGFRVRLEDGAEVNATGLTQDQMACYTQSYHATAYEVGITQTIYIGRACRVSGMERTKDGSIRHPHFDGFR\n>YP_249578#6 DNA ligase [Vibriophage VP4]   AAY46277.1|\nPEGEIDGTVVGVNWGTVGLANEGKVIGFQVLLENGVVVDANGITQEQMEEYTNLVYKTGHDDCFNGRPVQVKYMEKTPKGSLRHPSFQRWR\n>NP_877456#7 putative ATP-dependent DNA ligase [Bacteriophage phiKMV]\nPEITVDGRIVGYVMGKTGKNVGRVVGYRVELEDGSTVAATGLSEEHIQLLTCAYLNAHIDEAMPNYGRIVEVSAMERSANTLRHPSFSRFR\n>NP_813751#8 putative DNA ligase [Pseudomonas phage gh-1]   \nPDDNEDGFIQDVIWGTKGLANEGKVIGFKVLLESGHVVNACKISRALMDEFTDTETRLPGYYKGHTAKVTFMERYPDGSLRHPSFDSFR\n>CAK25951#9 putative ATP-dependent DNA ligase [Bacteriophage LKD16]\nPSLAVEGIVVGFVMGKTGANVGKVVGYRVDLEDGTIVSATGLTRDRIEMLTTEAELLGGADHPGMADLGRVVEVTAMERSANTLRHPKFSRFR"
}
