function inArray(needle, haystack) {
    var length = haystack.length;
    for(var i = 0; i < length; i++) {
        if(haystack[i] == needle) return true;
    }
    return false;
}


//Highlighting thingy
function gcv_highlight(id)
{
    document.getElementById("l"+id).style.backgroundColor="#aaffaa";
    document.getElementById("s"+id).style.display="inline";
    setTimeout("gcv_fade("+id+")",2000)
}
function gcv_fade(id)
{
    document.getElementById("l"+id).style.backgroundColor="transparent";
}
function cb(e)
{
    if (!e) var e = window.event;
    e.cancelBubble = true;
    if (e.stopPropagation) e.stopPropagation();
}

//Infobox thingy (although it says legend. It was late when I coded this...)
//ToDo: rename
function gcv_legend_on(gi,gene_name,descr,complement,start,end,prev_end,next_start)
{
    document.getElementById("gcv_infobox_gene").innerHTML="gi|"+gi+" "+(gene_name==gi?"":gene_name);
    document.getElementById("gcv_infobox_descr").innerHTML=descr;
    document.getElementById("gcv_infobox_location").innerHTML=start+(complement==1?" <- ":" -> ")+end+" ("+(end-start)+" bp / "+((end-start)/3)+" aa)";
    document.getElementById("gcv_infobox_inter").innerHTML=(prev_end!=-1?((start-prev_end)+" bp <| "):"")+gene_name+(next_start!=-1?(" |> "+(next_start-end)+" bp"):"");
    
    return overlib("<table style=width:400px><tr><td><b>Gene:</b></td><td>"+"gi|"+gi+" "+(gene_name==gi?"":gene_name)+"</td></tr><tr><td><b>Description:</b></td><td>"+descr+"</td></tr><tr><td><b>Location:</b></td><td>"+start+(complement==1?" <- ":" -> ")+end+" ("+(end-start)+" bp / "+((end-start)/3)+" aa)</td></tr><tr><td><b>Intergenic Distances:</b></td><td>"+(prev_end!=-1?((start-prev_end)+" bp <| "):"")+gene_name+(next_start!=-1?(" |> "+(next_start-end)+" bp"):"")+"</td></tr></table>");
}

function gcv_legend_off()
{
    return nd();
}

//Selection thingy

var gi_array = Array();

function gcv_select(gi)
{
  if (!inArray(gi, gi_array))
  {
    gi_array.push(gi);
  }

  gcv_write_array();

}


function gcv_delete(index)
{
  gi_array.splice(index,1);

  gcv_write_array();
}


function gcv_write_array()
{
  if(inx>0)
    scroll_start();
  var temp = "<table>";
  for (var i=0; i < gi_array.length; i++ )
  {
    temp += "<tr><td>"+gi_array[i]+"</td><td><a onClick=\"gcv_delete("+i+")\">X</a></td></tr>";
  }
  document.getElementById("gi_list").innerHTML = temp + "</table><p align=\"center\" style=\"border: 2px solid blue; padding: 1px; margin: 5px;\"><a href=\"http://"+window.location.host+"/gcview/?gi="+gi_array.join('x')+"&parentjob="+window.location.href.split("/").reverse()[0]+"\">Search again</a></p> <p align=\"center\" style=\"border: 2px solid blue; padding: 1px; margin: 5px;\"><a href=\"http://"+window.location.host+"/gi2seq/?gi="+gi_array.join('x')+"&parentjob="+window.location.href.split("/").reverse()[0]+"\">Retrieve Sequence</a></p>";
}


var scrolling;
var inx = -10;
function scroll_start()
{
scrolling=window.setInterval("do_scroll()",20);
}

function do_scroll()
{
var position=parseInt(document.getElementById("gi_list_container").style.right)+inx;
document.getElementById("gi_list_container").style.right=position+"px";
if ((inx < 0 && position <=-140) || (inx >0 && position >= 20))
        {
        inx=inx*-1;

        document.getElementById("gi_list_switch").innerHTML= (inx>0)?"&lt;<br/>&lt;":"&gt;<br/>&gt;";
        window.clearInterval(scrolling);
        }
}