function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  for(i = 0; i < (blocks*number); i++) {
    $(blammer_form).elements["hits[]"][i].checked = false;
  }
  calculate_forwarding();
}
function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  for(i = 0; i < (blocks*number); i++) {
    $(blammer_form).elements["hits[]"][i].checked = true;
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
        $(blammer_form).elements["hits[]"][(b*number+i)].checked = true;
      } else {
        $(blammer_form).elements["hits[]"][(b*number+i)].checked = false;      
      }
    }  
  }
  calculate_forwarding();
}

function change(num, block)
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  var mode = $(blammer_form).elements["hits[]"][(block * number)+num].checked;
  for (b = 0; b < (blocks); b++) {
    $(blammer_form).elements["hits[]"][(b * number)+num].checked = mode;
  }
}

function pasteExample()
{
  $('sequence_input').value = ">gi|33300828|ref|NP_877456#7 putative ATP-dependent DNA ligase [Bacteriophage phiKMV]\nPEITVDGRIVGYVMGKTG-KNVGRVVGYRVELEDGSTVAATGLSEEHIQLLTCAYLNAHI\nD---EAMPNYGRIVEVSAMERSAN-TLRHPSFSRFR\n>gi|114796395|emb|CAK25951#9 putative ATP-dependent DNA ligase [Bacteriophage LKD16]\nPSLAVEGIVVGFVMGKTG-ANVGKVVGYRVDLEDGTIVSATGLTRDRIEMLTTEAELLGG\nA-DHPGMADLGRVVEVTAMERSAN-TLRHPKFSRFR\n>gi|114796457|emb|CAK24995#5 putative DNA ligase [Bacteriophage LKA1]   E=4e-40 s/c=1.7\nPGFEADGTVIDYVWGDPDKANANKIVGFRVRLEDGAEVNATGLTQDQMACYTQSYHATAY\nEVGITQTIYIGRACRVSGMERTKDGSIRHPHFDGFR\n>gi|29366706|ref|NP_813751#8 putative DNA ligase [Pseudomonas phage gh-1]   gi|29243565\nPDDNEDGFIQDVIWGTKGLANEGKVIGFKVLLESGHVVNACKISRALMDEFTDTETRLPG\n-------YYKGHTAKVTFMERYPDGSLRHPSFDSFR\n>gi|68299729|ref|YP_249578#6 DNA ligase [Vibriophage VP4]   gi|66473268|gb|AAY46277.1|\nPEGEIDGTVVGVNWGTVGLANEGKVIGFQVLLENGVVVDANGITQEQMEEYTNLVYKTGH\nD-----DCFNGRPVQVKYMEKTPKGSLRHPSFQRWR\n>gi|77118174|ref|YP_338096#3 ligase [Enterobacteria phage K1F]   gi|72527918|gb|AAZ7297\nPSEEADGHVVRPVWGTEGLANEGMVIGFDVMLENGMEVSATNISRALMSEFTENVKSDP-\n------DYYKGWACQITYMEETPDGSLRHPSFDQWR\n>gi|17570796|ref|NP_523305#4 DNA ligase [Bacteriophage T3]   gi|118769|sp|P07717|DNLI_B\nPECEADGIIQGVNWGTEGLANEGKVIGFSVLLETGRLVDANNISRALMDEFTSNVKAHGE\nD------FYNGWACQVNYMEATPDGSLRHPSFEKFR\n>gi|119637753|ref|YP_91898#2 DNA ligase [Yersinia phage Berlin]   gi|119391784|emb|CAJ\nPECEADGIIQSVNWGTPGLSNEGLVIGFNVLLETGRHVAANNISQTLMEELTANAKEHGE\nD------YYNGWACQVAYMEETSDGSLRHPSFVMFR\n"
}