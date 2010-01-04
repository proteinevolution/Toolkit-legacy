function appearForward(val)
{
    if (Element.getStyle(val, 'display') == "none") {
	new Effect.Appear(val);
    } else {
	new Effect.Fade(val);
    }
}

function setFwAction(form, dest) 
{
    $(form).action = $(dest).options[$(dest).selectedIndex].value;
}

function setHook(id, list) 
{ 	
    $(id).value = $(list).options[$(list).selectedIndex].value;
}   

function setElement(id, val) 
{	
    setValue(id, val);	
}

function setAction(id, val) 
{	
    $(id).action = val;
}

function setTarget(id, val) 
{	
    $(id).target = val;
}

function setValue(id, val) 
{	
    $(id).value = val;
}

function getValue(id) 
{	
    return $(id).value;
}

function toggleDisabled(id)
{
    $(id).disabled = !$(id).disabled;
}

function toggleTarget(id)
{	
    if ($(id).target == '_self') {		
	$(id).target = '_blank';	
    } else {
	$(id).target = '_self';	
    }  
}

function toggleExport(form, dest)
{	
    if ($(form).target == '_blank') {	
	$(form).target = '_self';
    } else {
	$(form).target = '_blank';	
    }  
    $(form).action = $(dest).options[$(dest).options.selectedIndex].value;
}

function toggleForward(id)
{
    if (Element.getStyle(id, 'display') == "none") {
	new Effect.Appear(id);
    } else {
	new Effect.Fade(id);
    }
}

function openHelpWindow(url) 
{	
    var helpwindow = window.open(url,'helpwindow','width=950,height=700,left=0,top=0,scrollbars=yes,resizable=no'); 	
    helpwindow.focus();
}

function show_sitereq()
{	
/* if (!is_opera7up && !is_nav7up && !is_moz && !is_fx && !is_safari)	{
   $('sitereq').style.display = "block";		
   $('sitereqfull').style.display = "block"; 	
} */	
}

function show_periodicity()
{
    obj.visibility='show';
}

function MM_findObj(n, d) 
{
    var p,i,x;  
    if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {    
	d=parent.frames[n.substring(p+1)].document; 
	n=n.substring(0,p);
    }  
    if(!(x=d[n])&&d.all) 
	x=d.all[n]; 
    for (i=0;!x&&i<d.forms.length;i++) 
	x=d.forms[i][n];  
    for(i=0;!x&&d.layers&&i<d.layers.length;i++) 
	x=MM_findObj(n,d.layers[i].document);  
    if(!x && document.getElementById) 
	x=document.getElementById(n); 
    return x;
}

function MM_showHideLayers() 
{   
    var i,p,v,obj,args=MM_showHideLayers.arguments;  
    for (i=0; i<(args.length-2); i+=3) 
	if ((obj=MM_findObj(args[i]))!=null) { 
	    v=args[i+2];    
	    if (obj.style) { 
		obj=obj.style; 
		v=(v=='show')?'visible':(v='hide')?'hidden':v; 
	    }    
	    obj.visibility=v; 
	}
}

function openUserdbWindow(url) 
{
    var userdbwin = window.open(url,'userdbwindow','width=700,height=320,left=0,top=0,scrollbars=yes,resizable=no');
    userdbwin.focus(); 
}

function deselectjobs()
{
    var number = $(clear_checkboxes).value;
    if (number==1) {
	document.clearrecentjobs.elements["jobid[]"].checked = false;
    } else {
	for(i=0; i<number; i++) {
	    document.clearrecentjobs.elements["jobid[]"][i].checked = false;
	}
    }
}

function selectjobs()
{ 
    
    var number = $(clear_checkboxes).value;
    if (number==1) {
	document.clearrecentjobs.elements["jobid[]"].checked = true;
    } else {
	for(i=0; i<number; i++) {
	    document.clearrecentjobs.elements["jobid[]"][i].checked = true;
	}
    }
}

function sleep(numberMillis) 
{
    var now = new Date();
    var exitTime = now.getTime() + numberMillis;
    while (true) {
	now = new Date();
	if (now.getTime() > exitTime)
	    return;
    }
}

//Creates slider with to handles for selecting domains of a sequence (see hhpred or hhblast result page).
function domain_slider_show(sequence_length, start, end) {
  var s = $('slider_bar');
  new Control.Slider(s.select(".handle"), s, {
    range: $R(1, sequence_length, false),
    step: 1,
    sliderValue: [start, end],
    spans: [s.down('.span')],
    restricted: true,
    onSlide: function(v) {domain_slider_update(v);}
  });
  domain_slider_update(new Array(start, end));
}

function domain_slider_update(v) {
  var i = Math.floor(v[0]);
  $('domain_start').value = i;
  $('slider_label_left').innerHTML = i;
  $('slider_label_left').style.left = parseInt($('slider_bar_handle_left').style.left) - 17;
  var i = Math.floor(v[1]);
  $('domain_end').value = i;
  $('slider_label_right').innerHTML = i;
  $('slider_label_right').style.left = parseInt($('slider_bar_handle_right').style.left) + 2;
}

