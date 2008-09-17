function deselect(){
	var number = parseInt($('checkboxes').value, 10);
	for(i = 0; i < number; i++) {
		$('hit_checkbox'+i).checked=false;
		$('hit_checkbox'+(number+i)).checked=false;
  }
}

function select(){
	var number = parseInt($('checkboxes').value, 10);
	for(i = 0; i < number; i++) {
		$('hit_checkbox'+i).checked=true;
		$('hit_checkbox'+(number+i)).checked=true;
	}
}

function select_first(){
	first = 10
	var number = parseInt($('checkboxes').value, 10);
	for(i = 0; i < first; i++) {
		$('hit_checkbox'+i).checked=true;
		$('hit_checkbox'+(number+i)).checked=true;
	}
	for(i = first; i < number; i++) {
		$('hit_checkbox'+i).checked=false;
		$('hit_checkbox'+(number+i)).checked=false;
	}
}

function change(num, block){ 
	var number = parseInt($('checkboxes').value, 10);
	if(block==0){
		var mode = $('hit_checkbox'+num).checked;
		$('hit_checkbox'+(number+num)).checked=mode;
	}else{
		var mode = $('hit_checkbox'+(number+num)).checked;
		$('hit_checkbox'+num).checked=mode;
	}
}


function toggle_seqlen(list)
{
	var dest = $(list).options[$(list).selectedIndex].value;
	if (dest.indexOf('blastclust') != -1 || dest.indexOf('clans') != -1 || dest.indexOf('clustal') != -1 || 
	    dest.indexOf('kalign') != -1 || dest.indexOf('mafft') != -1 || dest.indexOf('muscle') != -1 ||
	    dest.indexOf('patsearch') != -1 || dest.indexOf('probcons') != -1) {
		$('seqlen_hsp').disabled = false;
		$('seqlen_complete').disabled = false;		
	} else {
		$('seqlen_hsp').disabled = true;
		$('seqlen_complete').disabled = true;		
	}
}