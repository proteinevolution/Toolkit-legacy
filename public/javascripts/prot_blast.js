function toggle_seqlen(list)
{
	var dest = $(list).options[$(list).selectedIndex].value;
	if (dest.indexOf('blastclust') != -1 || dest.indexOf('clans') != -1 || dest.indexOf('clustal') != -1 || 
	    dest.indexOf('kalign') != -1 || dest.indexOf('mafft') != -1 || dest.indexOf('muscle') != -1 ||
	    dest.indexOf('patsearch') != -1 || dest.indexOf('probcons') != -1) {
		$('seqlen_slider').disabled = false;		
		$('seqlen_complete').disabled = false;		
	} else {
		$('seqlen_slider').disabled = true;		
		$('seqlen_complete').disabled = true;		
	        if ($('seqlen_complete').checked == true) {
			$('seqlen_slider').checked = true;
		}
	}
}

function test(){
	alert((($(destination))[0]).getAttribute('acceptance'))
}
function pasteExample()
{
  $('sequence_input').value = ">gi|4557853|ref|NP_000337.1| transcription factor SOX-9 [Homo sapiens]\nMNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAG\
SPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFP\nVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG\nKLWRLLNESEKRPFVEEAERLRV\
QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQAD\nSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSS\nDVISNIETFDVNEF\
DQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPP\nQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAY\nSPFNL\
PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIP\nQTHSPQHWEQPVYTQLTRP";
  // $('std_dbs').options.selectedIndex = 2;  
  // onSimpleClick(null, "user_dbs");
}
