function setMoreHomologs() {
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


function setPdb() {
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


