function showApplet(id){

	if (is_opera5up) {
		var height = screen.height - (screen.height*0.2);
		var width = screen.width - (screen.width*0.05);
	}
	else
	{
		var height = "520px";
		var width = "820px";
	}
	var w = window.open("/ali2d/results_show_applet/" + id, 'appletwindow',"outerWidth=" + width + ",outerHeight=" + height + ",left=0,top=0"); 
	w.focus();
}