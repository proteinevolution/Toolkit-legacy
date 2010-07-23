function toggle_ali(){

        if( $('aln_file').value=="Hide alignment" ){
                Effect.Fade('aln');
                $('aln_file').value="Show alignment";
        }else{
                Effect.Appear('aln');
                $('aln_file').value="Hide alignment";
        }
}


function toggle_sp_table(){

        if( $('sp_table').value=="Hide SP_table" ){
                Effect.Fade('sp');
                $('sp_table').value="Show SP_table";
        }else{
                Effect.Appear('sp');
                $('sp_table').value="Hide SP_table";
        }
}

