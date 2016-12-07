function setMoreHomologs() 
{
	if ($('moreHomologs').value == 'true') {
		Effect.Fade('psiblast_options');
		$('moreHomologs').value = 'false';
		$('seqCentered').checked = false;
	} else {
		Effect.Appear('psiblast_options');
		$('seqCentered').checked = true;
		$('moreHomologs').value = 'true';
	}
}


function check_pdb(){
	if($('pdb_file').value!=''){
		$('solv_acc').disabled = true; 
		$('solv_acc').checked = false;
	}else{
		$('solv_acc').disabled = false;	
		$('solv_acc').checked = true;	
	}
}


function setPdb() 
{
	if ($('pdb_check').checked) {
		Effect.Fade('pdb_options');
		$('pdb_check').checked = true;
		$('pdb_check').disabled = false;
	} else {
		Effect.Appear('pdb_options');
		$('pdb_check').checked = false;
		$('pdb_check').disabled = false;
	}
}

function pasteExample() {
    document.getElementById('sequence_input').value = ">1a0i241-349\nPENEADGIIQGLVWGTKGLANEGKVIGFEVLLESGRLVNATNISRALMDEFTETVKEATLSQWGFFDACTINPYDGWACQISYMEETPDGSLRHPSFVMFR\n>YP_91898#2 DNA ligase [Yersinia phage Berlin]   CAJ\nPECEADGIIQSVNWGTPGLSNEGLVIGFNVLLETGRHVAANNISQTLMEELTANAKEHGE-----------DYYNGWACQVAYMEETSDGSLRHPSFVMFR\n>YP_338096#3 ligase [Enterobacteria phage K1F]   AAZ7297\nPSEEADGHVVRPVWGTEGLANEGMVIGFDVMLENGMEVSATNISRALMSEFTENVKSDP------------DYYKGWACQITYMEETPDGSLRHPSFDQWR\n>NP_523305#4 DNA ligase [Bacteriophage T3]   P07717|DNLI_B\nPECEADGIIQGVNWGTEGLANEGKVIGFSVLLETGRLVDANNISRALMDEFTSNVK-----------AHGEDFYNGWACQVNYMEATPDGSLRHPSFEKFR\n>CAK24995#5 putative DNA ligase [Bacteriophage LKA1]   E=4e-40 s/c=1.7\nPGFEADGTVIDYVWGDPDKANANKIVGFRVRLEDGAEVNATGLTQDQMACYTQSY-HATAYEVGI----TQTIYIGRACRVSGMERTKDGSIRHPHFDGFR\n>YP_249578#6 DNA ligase [Vibriophage VP4]   AAY46277.1|\nPEGEIDGTVVGVNWGTVGLANEGKVIGFQVLLENGVVVDANGITQEQMEEYTNLVYKTG------HDDC----FNGRPVQVKYMEKTPKGSLRHPSFQRWR\n>NP_877456#7 putative ATP-dependent DNA ligase [Bacteriophage phiKMV]\nPEITVDGRIVGYVMGKTGK-NVGRVVGYRVELEDGSTVAATGLSEEHIQLLTCAYLNA-------HIDEAMPNY-GRIVEVSAMERSAN-TLRHPSFSRFR\n>NP_813751#8 putative DNA ligase [Pseudomonas phage gh-1]   \nPDDNEDGFIQDVIWGTKGLANEGKVIGFKVLLESGHVVNACKISRALMDEFTDT--ETRLPG----------YYKGHTAKVTFMERYPDGSLRHPSFDSFR\n>CAK25951#9 putative ATP-dependent DNA ligase [Bacteriophage LKD16]\nPSLAVEGIVVGFVMGKTG-ANVGKVVGYRVDLEDGTIVSATGLTRDRIEMLT------TEAELLGGADHPGMADLGRVVEVTAMERSAN-TLRHPKFSRFR"
    document.getElementById('inputmode_sequence').checked = false;
    document.getElementById('inputmode_alignment').checked = true;
    document.getElementById('maxpsiblastit').value = 1;
}
