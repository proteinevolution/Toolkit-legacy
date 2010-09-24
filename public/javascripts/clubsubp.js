function clubsub_toggle(id){
        var tab = document.getElementById(id);
        var bExpand = tab.style.display == 'none';
        if(bExpand == true){
                tab.style.display = "";
        }
}

function clubsub_toggle_hide(id){
        var tab = document.getElementById(id);
        var bExpand = tab.style.display == '';
        if(bExpand == true){
                tab.style.display = "none";
        }
}
