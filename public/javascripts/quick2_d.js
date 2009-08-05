function initInfo(){
	divObj = document.createElement("pre");
	divObj.style.position = "fixed";
	divObj.id = "infoDiv";
	divObj.innerHTML = ""
	divObj.style.left = "120px";
	divObj.style.top = "120px";
	divObj.style.width = "160px";
	divObj.style.height = "190px";
	divObj.style.backgroundColor="#eff5ef";
	divObj.style.visibility="hidden";
	divObj.style.border="solid 1px #cccccc";
	divObj.style.padding="2px";
	divObj.style.zIndex=1001
	preObj = document.getElementById("queryname");
	preObj.appendChild(divObj);
	divObj.aa = new aminoObj();
}

function showInfo(id){
	var x = 0;
	var y = 0;
	var obj = document.getElementById(id);
	var tmpobj = obj;
	while(tmpobj.offsetParent){
		x += parseInt(tmpobj.offsetParent.offsetLeft);
		y += parseInt(tmpobj.offsetParent.offsetTop);
		tmpobj = tmpobj.offsetParent;
	}
	x += parseInt(obj.offsetLeft);
	y += parseInt(obj.offsetTop);
	
	x -= parseInt(window.pageXOffset);
	y -= parseInt(window.pageYOffset);
	
	if( x > parseInt(window.innerWidth)){
		x -= parseInt(divObj.style.width);
	}
	
	divObj.style.top = (y-parseInt(divObj.style.height)-10)+"px";
	divObj.style.left = (x+10)+"px";
	divObj.style.visibility="visible";
	var resPos = parseInt(obj.id);
	divObj.innerHTML = "<pre><b>Confidences (Pos:" + (resPos+1) + ")</b></br>";
	if(divObj.aa[RESIDUES.charAt(resPos)]){
		divObj.innerHTML += "<b>" + divObj.aa[RESIDUES.charAt(resPos)] + " </b>";
	}
	divObj.innerHTML += "<b>(" + RESIDUES.charAt(resPos) + ")</b></br>";
	

	if( typeof(PSIPRED_CONF)!="undefined" && PSIPRED_CONF.length>0){
		divObj.innerHTML += "PSIPRED     : " + PSIPRED_CONF[resPos] + "\n";
	}
	if( typeof(JNET_CONF)!="undefined" && JNET_CONF.length>0){
		divObj.innerHTML += "JNET        : " + JNET_CONF[resPos] + "\n";
	}
	if( typeof(PROFROST_CONF)!="undefined" && PROFROST_CONF.length>0){
		divObj.innerHTML += "PROF(Rost)  : " + PROFROST_CONF[resPos] + "\n";
	}
	if( typeof(PROFOUALI_CONF)!="undefined" && PROFOUALI_CONF.length>0){
		divObj.innerHTML += "Prof(Ouali) : " + PROFOUALI_CONF[resPos] + "\n";
	}
	if( typeof(PROFROST_TMCONF)!="undefined" && PROFROST_TMCONF.length>0){
		divObj.innerHTML += "TM(Rost)    : " + PROFROST_TMCONF[resPos] + "\n";
	}
	if( typeof(MEMSATSVM_TMCONF)!="undefined" && MEMSATSVM_TMCONF.length>0){
		divObj.innerHTML += "MEMSAT-SVM  : " + MEMSATSVM_TMCONF[resPos] + "\n";
	}
	if( typeof(DISOPRED2_CONF)!="undefined" && DISOPRED2_CONF.length>0){
		divObj.innerHTML += "DISOPRED2   : " + DISOPRED2_CONF[resPos] + "\n";
	}
	if( typeof(IUPRED_CONF)!="undefined" && IUPRED_CONF.length>0){
		divObj.innerHTML += "IUPRED      : " + IUPRED_CONF[resPos] + "\n";
	}
}

function hideInfo(){
	divObj.style.visibility="hidden";
}

function showProperties(obj){
	var wh=window.open("", "", "width=300,height=400,left=0,top=0");
	wh.document.write("<body><pre>");
	for(var i in obj){		
		wh.document.write(i+" "+obj[i]+"\n");
	}
	
	if(obj.style){
		for(var i in obj.style){		
			wh.document.write(i+" "+obj[i]+"\n");
		}
	}
	wh.document.write("</pre></body>");
}

function aminoObj(){
	this.A="Alanine";
	this.P="Proline";
   this.B="Aspartate or Asparagine";
   this.Q="Glutamine";
   this.C="Cystine";
	this.R="Arginine";
	this.D="Aspartate";
	this.S="Serine";
	this.E="Glutamate";
	this.T="Threonine";
	this.F="Phenylalanine";                   
	this.U="Selenocysteine";
   this.G="Glycine";
   this.V="Valine";
   this.H="Histidine";
  	this.W="Tryptophan";
	this.I="Isoleucine";
	this.Y="Tyrosine";
   this.K="Lysine";                          
   this.Z="Glutamate or Glutamine";
   this.L="Leucine";
	this.X="any";
   this.M="Methionine";
   this.N="Asparagine";
}