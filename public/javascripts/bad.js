function expand(thistag){
   styleObj=document.getElementById(thistag).style;
   if(styleObj.display=='none'){styleObj.display='';}
   else {styleObj.display='none';}
}

function expandCollapse() {
for (var i=0; i<expandCollapse.arguments.length; i++) {
var element = document.getElementById(expandCollapse.arguments[i]);
element.style.display = (element.style.display == "none") ? "block" : "none";
	}
}

function toggle_ali(){

	if( $('ali_btn').value=="Hide alignment" ){
		Effect.Fade('ali');
		$('ali_btn').value="Show alignment";
	}else{
		Effect.Appear('ali');
		$('ali_btn').value="Hide alignment";
	}
}
