function deselect()
{
	
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10) + 1;
  for(i = 0; i < (blocks*number); i++) {
    $(t_coffee_form).elements["hits[]"][i].checked = false;
  }
}
function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10) + 1;
  for(i = 0; i < (blocks*number); i++) {
    $(t_coffee_form).elements["hits[]"][i].checked = true;
  }
}
function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10) + 1;
  var first = 10;
  for(b = 0; b < blocks; b++) {
    for (i = 0; i < number; i++) {
      if (i < first) {
        $(t_coffee_form).elements["hits[]"][(b*number+i)].checked = true;
      } else {
        $(t_coffee_form).elements["hits[]"][(b*number+i)].checked = false;      
      }
    }  
  }
}

function change(num, block)
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  var mode = $(t_coffee_form).elements["hits[]"][(block * number)+num].checked;
  for (b = 0; b < (blocks + 1); b++) {
    $(t_coffee_form).elements["hits[]"][(b * number)+num].checked = mode;
  }
}