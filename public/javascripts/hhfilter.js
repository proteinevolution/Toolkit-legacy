function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(hhfilter_form).elements["hits[]"][i].checked = false;
  }
  calculate_forwarding();
}
function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(hhfilter_form).elements["hits[]"][i].checked = true;
  }
  calculate_forwarding();
}
function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var first = 10;
  for (i = 0; i < number; i++) {
    if (i < first) {
      $(hhfilter_form).elements["hits[]"][(i)].checked = true;
    } else {
      $(hhfilter_form).elements["hits[]"][(i)].checked = false;      
    }
  }
  calculate_forwarding();
}