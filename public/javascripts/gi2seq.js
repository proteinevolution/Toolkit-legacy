function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(gi2seq_form).elements["hits[]"][i].checked = false;
  }
  calculate_forwarding();
}
function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(gi2seq_form).elements["hits[]"][i].checked = true;
  }
  calculate_forwarding();
}
function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var first = 10;
  for (i = 0; i < number; i++) {
    if (i < first) {
      $(gi2seq_form).elements["hits[]"][(i)].checked = true;
    } else {
      $(gi2seq_form).elements["hits[]"][(i)].checked = false;      
    }
  }
  calculate_forwarding();
}

function pasteExample()
{
  $('sequence_input').value = "114796395\n114796457\n33300828\n119391784\n29366706\n118769\n66473268\n72527918"
}