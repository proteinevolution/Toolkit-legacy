// Put your javascript code here!
function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(blastclust_form).elements["hits[]"][i].checked = false;
  }
}

function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  for(i = 0; i < (number); i++) {
    $(blastclust_form).elements["hits[]"][i].checked = true;
  }
}

function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var first = 10;
  for (i = 0; i < number; i++) {
    if (i < first) {
      $(blastclust_form).elements["hits[]"][(i)].checked = true;
    } else {
      $(blastclust_form).elements["hits[]"][(i)].checked = false;      
    }
  }
}