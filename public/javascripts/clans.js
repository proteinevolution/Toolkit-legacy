function toggleFields(val)
{
	if (val == "linkage") {
		$('minLinks').disabled = false;

		$('stdev').disabled = true;
		$('globalaverage').disabled = true;
		$('offset').disabled = true;
	} else {
		if (val == "convex") {
			$('stdev').disabled = false;
			
			$('minLinks').disabled = true;
			$('globalaverage').disabled = true;
			$('offset').disabled = true;
		} else {
			$('globalaverage').disabled = false;
			$('offset').disabled = false;
			
			$('minLinks').disabled = true;
			$('stdev').disabled = true;
		}
	}
}

var xoffset=82;
var maxval=1;
var graphwidth=605;
var graphoffset=75;
var graphheight=400;

function init_clans() {
	$('divline').style.top = "275px";
}

function init_cluster() {
	$('divline').style.top = "313px";
}

function init(){
    img = $('graph');
    img.addEventListener('click',setxcoord,false);
    maxvalobj = $('maxval');
    maxval = maxvalobj.value;
    cutoffline =  $('divline');
    cutoffline.style.left = xoffset+"px";
}

function setxcoord(e){
   var cutoff = $('xcutoff');
	var posx = 0;
	var posy = 0;
	if (!e){
	    var e = window.event;
	}
	if (e.layerX || e.layerY){
		posx = e.layerX;
		posy = e.layerY;
	}else if (e.clientX || e.clientY){
		posx = e.clientX + document.body.scrollLeft;
		posy = e.clientY + document.body.scrollTop;
		cutoff.value="enter manually";
	}
	posx=posx-xoffset;
	if(posx<0){
	    posx=0;
	}else if(posx>graphwidth){
	    posx=graphwidth;
	}
	cutoff.value = (posx/graphwidth)*maxval;
	cutoffline = $('divline');
	cutoffline.style.left = (posx+xoffset)+"px";
}