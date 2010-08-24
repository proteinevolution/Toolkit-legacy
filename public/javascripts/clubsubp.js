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
//		Effect.Appear('sp_table');
                $('sp_table').value="Show SP_table";
        }else{
                Effect.Appear('sp') ;
//		Effect.Fade('sp_table');
                $('sp_table').value="Hide SP_table";
        }
}



function toggle_genome_tree(){

        if( $('genome_tree').value=="Hide genome_tree" ){
                Effect.Fade('tree');
                $('genome_tree').value="Show genome_tee";
        }else{
                Effect.Appear('tree');
                $('genome_tree').value="Hide genome_tree";
        }
}

