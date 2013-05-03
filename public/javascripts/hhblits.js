function change_format()
{
    var informat = $("informat");
    var disable = false;
    for( i=0; i<informat.length; i++ ) {
	if (informat.options[i].selected == true && (informat.options[i].value == "a2m" || informat.options[i].value == "a3m")) {
	    disable = true;
	}
    }
    $('match_modus').disabled = disable;
}

function change_db(dbhhm, dba3m)
{
    var dbhhms = dbhhm.split(";");
    var dba3ms = dba3m.split(";");
    var dblist = $("hhblits_dbs");
    for( i=0; i<dblist.length; i++ ) {
	if (dblist.options[i].selected == true) {
	    $('dbhhm').value = dbhhms[i];
	    $('dba3m').value = dba3ms[i];
	}
    }
    
}

function appearForwardHHM(val)
{ 
	var coloring = 'color_button';
	var image = 'hitlist_img';
	var forward = 'forward'
	
	if (Element.getStyle(val, 'display') == "none") {
		if(Element.getStyle(forward, 'display') != "none"){
			Effect.Fade(forward);
		}
		if($(coloring) != null){
			new Effect.Fade(coloring);
		}
		new Effect.Fade(image);
		new Effect.Fade(forward);
		sleep(1000);
		new Effect.Appear(val);
	} else {
		new Effect.Fade(val);
		if($(coloring) != null) {
			new Effect.Appear(coloring);
		}
		new Effect.Appear(image);
	}
}

function appearForward(val)
{
    var coloring = 'color_button';
    var image = 'hitlist_img';
    var forward = 'forward';
    var forwardhhm = 'forwardhhm';
    
    if (Element.getStyle(val, 'display') == "none") {
		if ($(coloring) != null) {
		    new Effect.Fade(coloring);
		}
		if (Element.getStyle(forwardhhm, 'display') != "none"){
			new Effect.Fade(forwardhhm);
		}
		new Effect.Fade(forward);
		new Effect.Fade(image);
		sleep(1000);
		new Effect.Appear(val);
    } else {
		new Effect.Fade(val);
		if ($(coloring) != null) {
		    new Effect.Appear(coloring);
		}
		new Effect.Appear(image);
    }
}

function imgOn(imgName, imgSrc) {
    if (document.images) {
	document[imgName].src = imgSrc;
    }
}

function imgOff(imgName, imgSrc) {
    if (document.images) {
	document[imgName].src = imgSrc;
    }
}

function deselect()
{
    var number = parseInt($('checkboxes').value, 10);
    for(i = 0; i < number; i++) {
	$('hit_checkbox'+i).checked=false;
	$('hit_checkbox'+(number+i)).checked=false;
    }
    calculate_forwarding();
}
function select()
{
    var number = parseInt($('checkboxes').value, 10);
    for(i = 0; i < number; i++) {
	$('hit_checkbox'+i).checked=true;
	$('hit_checkbox'+(number+i)).checked=true;
    }
    calculate_forwarding();
}

function select_first(first)
{
	
    var number = parseInt($('checkboxes').value, 10);
    if (first > number) {
	first = number;
    }  
    for(i = 0; (i < first && i < number); i++){
  	if ($('hit_checkbox'+i).disabled == true) {
  	    first++;
  	} else {
  	    $('hit_checkbox'+i).checked=true;
	    $('hit_checkbox'+(number+i)).checked=true;
	}
    }
    for(i = first; i < number; i++) {
  	$('hit_checkbox'+i).checked=false;
	$('hit_checkbox'+(number+i)).checked=false;
    }
    calculate_forwarding();
}

function change(num, block)
{ 
    var number = parseInt($('checkboxes').value, 10);
    if (block == 0) {
	var mode = $('hit_checkbox'+(num-1)).checked;
	$('hit_checkbox'+(number+num-1)).checked=mode;
    } else {
	var mode = $('hit_checkbox'+(number+num-1)).checked;
	$('hit_checkbox'+(num-1)).checked=mode;
    }
    calculate_forwarding();
}

function change_radio(num, block)
{ 	
    var number = parseInt($('checkboxes').value, 10);
    $('hit_checkbox'+(num-1)).checked=true;
    $('hit_checkbox'+(number+num-1)).checked=true;
    
}

function show_applet() {	
    if (!is_opera7up && !is_nav7up && !is_moz && !is_fx && !is_safari && !is_ie6up) {		
	$('applet').style.display = "block";
    }	
}


function extract_selected(){
    var number = parseInt($('checkboxes').value, 10);
    var selected = "";
    for(i = 0; i < number; i++){
  	if($('hit_checkbox'+i).checked) selected += (i+1)+" ";
    }
    $('hits').value=selected;
}

function show_hide_more_options() {
    if ($('more_options_on').value == 'true') {
	Effect.Fade('more_options');
 	Effect.Fade('hide_more_options', { duration: 0.0 });
 	Effect.Appear('show_more_options', { duration: 0.0 });
	$('more_options_on').value = 'false';

    } else {
 	Effect.Appear('more_options');
 	Effect.Fade('show_more_options', { duration: 0.0 });
 	Effect.Appear('hide_more_options', { duration: 0.0 });
 	$('more_options_on').value = 'true';
    }
}

function select_genomes() {

    if ($('genomes_first').value == 'true') {

	$('genomes_first').value = 'false';
	dblist = $('hhpred_dbs');
        for( i=0; i<dblist.length; i++ ) dblist.options[i].selected = false;

    }
}

function change_resubmit_form_to_hhblits() {
    var expression = /(.+controller=)hhpred(.+)/;
    expression.exec($(forward_alignment).action);
    $(forward_alignment).action = RegExp.$1 + "hhblits" + RegExp.$2;
}


function pasteExample()
{
  $('sequence_input').value = ">gi|147642904|sp|Q5FVL3.2|FA69B_RAT RecName: Full=Protein FAM69B; AltName: Full=Pancreatitis-induced protein 49; Short=PIP49\nMRRLRRLVHLVLLCPFSKGLQGRLPGLRVKYVLLVWLGIFVGSWMVYVHYSSYSELCRGHVCQVVICDQY\nQKGIISGSVCQDLCELQKVEWRTCLSSAPGQQVYSGLWQDKEVTIKCGIEEALNSKAWPDAVPRRELVLF\nDKPTRGTSIKEFREMTLSFLKANLGDLPSLPALVDQILLMADFNKDSRVSLAEAKSVWALLQRNEFLLLL\nSLQEKEHASRLLGYCGDLYLTESIPHGSWHGAVLLPALRPLLPSVLHRALQQWFGPAWPWRAKIAIGLLE\nFVEELFHGSYGTFYMCETTLANVGYTATYDFKMADLQQVAPEATVRRFLQGRHCEQSSDCIYGRDCRAPC\nDKLMRQCKGDLIQPNLAKVCELLRDYLLPGAPADLYEELGKQLRTCTTLSGLASQVEAHHSLVLSHLKTL\nLWREISNTNYS";  
}


