function setHydro()
{
	if (document.repper_form.criteria[1].checked) {
		$('ala').value = 0;
		$('arg').value = 0;
		$('asn').value = 0;
		$('asp').value = 0;
		$('cys').value = 0;
		$('gln').value = 0;
		$('glu').value = 0;
		$('gly').value = 0;
		$('his').value = 0;
		$('ile').value = 1;
		$('leu').value = 1;
		$('lys').value = 0;
		$('met').value = 1;
		$('phe').value = 0;
		$('pro').value = 0;
		$('ser').value = 0;
		$('thr').value = 0;
		$('trp').value = 0;
		$('tyr').value = 0;
		$('val').value = 1;
	} else {
		$('ala').value = 1.8;
		$('arg').value = -4.5;
		$('asn').value = -3.5;
		$('asp').value = -3.5;
		$('cys').value = 2.5;
		$('gln').value = -3.5;
		$('glu').value = -3.5;
		$('gly').value = -0.4;
		$('his').value = -3.2;
		$('ile').value = 4.5;
		$('leu').value = 3.8;
		$('lys').value = -3.9;
		$('met').value = 1.9;
		$('phe').value = 2.8;
		$('pro').value = -1.6;
		$('ser').value = -0.8;
		$('thr').value = -0.7;
		$('trp').value = -0.9;
		$('tyr').value = -1.3;
		$('val').value = 4.2;
	}
}

//function checkPerRange()
//{
//   if (!document.getElementById) return false;
//	var o_winsize = document.getElementById('winsize');
//	var o_maxper = document.getElementById('maxper');

//	if(parseInt(o_maxper.value) > parseInt(o_winsize.value) ) {
//		o_maxper.value = o_winsize.value;
//	} 
//}

function setSequence()
{
	$('sequence_input').value = ">gi|401465|sp|P31489|YDA1_YEREN Adhesin yadA precursor\nMTKDFKISVSAALISALFSSPYAFADDYDGIPNLTAVQISPNADPALGLEYPVRPPVPGAGGLNASAKGI\nHSIAIGATAEAAKGAAVAVGAGSIATGVNSVAIGPLSKALGDSAVTYGAASTAQKDGVAIGARASTSDTG\nVAVGFNSKADAKNSVAIGHSSHVAANHGYSIAIGDRSKTDRENSVSIGHESLNRQLTHLAAGTKDTDAVN\nVAQLKKEIEKTQENTNKRSAELLANANAYADNKSSSVLGIANNYTDSKSAETLENARKEAFAQSKDVLNM\nAKAHSNSVARTTLETAEEHANSVARTTLETAEEHANKKSAEALASANVYADSKSSHTLKTANSYTDVTVS\nNSTKKAIRESNQYTDHKFRQLDNRLDKLDTRVDKGLASSAALNSLFQPYGVGKVNFTAGVGGYRSSQALA\nIGSGYRVNENVALKAGVAYAGSSDVMYNASFNIEW";
}
