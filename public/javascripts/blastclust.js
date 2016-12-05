// Put your javascript code here!
function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(blastclust_form).elements["hits[]"][i].checked = false;
  }
  calculate_forwarding();
}

function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(blastclust_form).elements["hits[]"][i].checked = true;
  }
  calculate_forwarding();
}

function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var first = 10;
  for (i = 0; i < number; i++) {
    if (i < first) {
      $(blastclust_form).elements["hits[]"][(i)].checked = true;
    } else {
      $(blastclust_form).elements["hits[]"][(i)].checked = false;      
    }
  }
  calculate_forwarding();
}

function pasteExample()
{
  document.getElementById('sequence_input').value =
">1a0i241-349\nPENEADGIIQGLVWGTKGLANEGKVIGFEVLLESGRLVNATNISRALMDEFTETVKEATLSQWGFFDACTINPYDGWACQISYMEETPDGSLRHPSFVMF\n>YP_91898#2 DNA ligase [Yersinia phage Berlin]   CAJ\nPECEADGIIQSVNWGTPGLSNEGLVIGFNVLLETGRHVAANNISQTLMEELTANAKEHGEDYYNGWACQVAYMEETSDGSLRHPSFVMF\n>YP_338096#3 ligase [Enterobacteria phage K1F]   AAZ7297\nPSEEADGHVVRPVWGTEGLANEGMVIGFDVMLENGMEVSATNISRALMSEFTENVKSDPDYYKGWACQITYMEETPDGSLRHPSFDQW\n>NP_523305#4 DNA ligase [Bacteriophage T3]   P07717|DNLI_B\nPECEADGIIQGVNWGTEGLANEGKVIGFSVLLETGRLVDANNISRALMDEFTSNVKAHGEDFYNGWACQVNYMEATPDGSLRHPSFEKF\n>CAK24995#5 putative DNA ligase [Bacteriophage LKA1]   E=4e-40 s/c=1.7\nPGFEADGTVIDYVWGDPDKANANKIVGFRVRLEDGAEVNATGLTQDQMACYTQSYHATAYEVGITQTIYIGRACRVSGMERTKDGSIRHPHFDGF\n>YP_249578#6 DNA ligase [Vibriophage VP4]   AAY46277.1|\nPEGEIDGTVVGVNWGTVGLANEGKVIGFQVLLENGVVVDANGITQEQMEEYTNLVYKTGHDDCFNGRPVQVKYMEKTPKGSLRHPSFQRW\n>NP_877456#7 putative ATP-dependent DNA ligase [Bacteriophage phiKMV]\nPEITVDGRIVGYVMGKTGKNVGRVVGYRVELEDGSTVAATGLSEEHIQLLTCAYLNAHIDEAMPNYGRIVEVSAMERSANTLRHPSFSRF\n>NP_813751#8 putative DNA ligase [Pseudomonas phage gh-1]\nPDDNEDGFIQDVIWGTKGLANEGKVIGFKVLLESGHVVNACKISRALMDEFTDTETRLPGYYKGHTAKVTFMERYPDGSLRHPSFDSF\n>CAK25951#9 putative ATP-dependent DNA ligase [Bacteriophage LKD16]\nPSLAVEGIVVGFVMGKTGANVGKVVGYRVDLEDGTIVSATGLTRDRIEMLTTEAELLGGADHPGMADLGRVVEVTAMERSANTLRHPKFSRF"
}
