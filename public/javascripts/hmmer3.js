function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(hmmer3_form).elements["hits[]"][i].checked = false;
  }
  calculate_forwarding();
}
function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(hmmer3_form).elements["hits[]"][i].checked = true;
  }
  calculate_forwarding();
}
function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var first = 10;
  for(i = 0; i < (number); i++) {
    if (i < first || (i >= number && i < (number+first))) {
      $(hmmer3_form).elements["hits[]"][i].checked = true;
    } else {
      $(hmmer3_form).elements["hits[]"][i].checked = false;
    }
  }
  calculate_forwarding();
}

function change(num, block)
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var mode = $(hmmer3_form).elements["hits[]"][(block * number)+num].checked;
  for (i = 0; i < 2; i++) {
    $(hmmer3_form).elements["hits[]"][(i * number)+num].checked = mode;
  }
}
