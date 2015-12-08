var highlightedIds = {}

var colors = [['#ff0000', '#e67373'], 
	      ['#ffe6e6', '#e6cfcf'],
	      ['#3aff00', '#8de673'],
	      ['#ebffe6', '#d4e6cf'],
	      ['#00b069', '#4f9e7e'],
	      ['#e6fff5', '#cfe6dc'],
	      ['#990000', '#804040'],
	      ['#ff6666', '#bf3030'],
	      ['#239900', '#4e8040'],
	      ['#89ff66', '#50bf30'], 
	      ['#006a3f', '#408066'],
	      ['#66ffc1', '#30bf85']]

colornum = 0

function prepareAlignmentLines(query, annotation, domains, cssids, lineLength) {
    var residueCounter = 0;
    var queryLines = new Array("");
    var annotationLines = new Array("");
    lineLength = parseInt(lineLength)
    for (d = 0; d < domains.length; d++) {
	queryLines[queryLines.length - 1] += "<span id=\'queryaln" + d.toString() + "\' onclick=\'toggleHighlighting(" + d.toString() + ")\'><span class=\'" + cssids[d].toString() + "\'>";
	annotationLines[queryLines.length - 1] += "<span id=\'annaln" + d.toString() + "\'><span class=\'" + cssids[d].toString() + "\'>";
	for (r = 0; r < query[d].length; r++) {
	    if (residueCounter == lineLength) {
		residueCounter = 0;
		queryLines[queryLines.length - 1] += "</span></span>";
		annotationLines[annotationLines.length - 1] += "</span></span>";
		queryLines.push("<span id=\'queryaln" + d.toString() + "\' onclick=\'toggleHighlighting(" + d.toString() + ")\'><span class=\'" + cssids[d].toString() + "\'>");
		annotationLines.push("<span id=\'annaln" + d.toString() + "\'><span class=\'" + cssids[d].toString() + "\'>");
	    }
	    queryLines[queryLines.length - 1] += query[d][r];	    
	    annotationLines[annotationLines.length - 1] += annotation[d][r];
	    residueCounter++;
	}
	queryLines[queryLines.length - 1] += "</span></span>";
	annotationLines[annotationLines.length - 1] += "</span></span>";
    }
    queryLines[queryLines.length - 1] += "</span></span>";
    annotationLines[queryLines.length - 1] += "</span></span>";
    return {query:queryLines, annotation:annotationLines}
}

function reshapeAlignment(query, annotation, domains, cssids, lineLength) { 
    var html = "";
    var positionStepSize = 20;
    var positionLine = "";
    var lines = prepareAlignmentLines(query, annotation, domains, cssids, lineLength);
    var seqlength = query.join("").length;
    for (i = 0; i < lines.query.length; i++) {
	html += "<li id=\'alignment-pline\'><span id=\'alignment-label\'>&nbsp;</span>";
	positionLine = "";
	for (p = i * lineLength + 1; p < Math.min((i + 1) * lineLength + 1, seqlength); p++) {
	    if (positionLine.length < p - i * lineLength) {
		if (p % positionStepSize == 1) {
		    positionLine += p.toString();
		} else {
		    positionLine += " ";
		}
	    }
	}
	html += positionLine.replace(/ /g, "&nbsp;") + "</li>";
	html += "<li id=\'alignment-qline\'><span id=\'alignment-label\'>" 
	html += qryidentifier + "</span>";
	html += lines.query[i] + "</li>";
	html += "<li id=\'alignment-aline\'><span id=\'alignment-label\'>annotation</span>";
	html += lines.annotation[i] + "</li>";
	document.getElementById("dataa2alignment").innerHTML = html;
    }
}

function unhighlightall() {
    for (var key in highlightedIds) {
	unhighlight(key);
	highlightedIds[key] = 0
    }
}

function unhighlight(id) {
    document.getElementById('domobject' + id).style.stroke = 'black';
    document.getElementById('domobject' + id).style.strokeWidth = '1'
    document.getElementById('queryaln' + id).style.border = '0px solid';
    document.getElementById('annaln' + id).style.border = '0px solid';
    document.getElementById('tableentry_' + id).style.backgroundColor = ''
}

function highlight(id, strong, pale) {
    document.getElementById('domobject' + id).style.stroke = strong;
    document.getElementById('domobject' + id).style.strokeWidth = '5';
    document.getElementById('queryaln' + id).style.border = '2px solid';
    document.getElementById('queryaln' + id).style.borderColor = strong;
    document.getElementById('annaln' + id).style.border = '2px solid';
    document.getElementById('annaln' + id).style.borderColor = 'white';
    document.getElementById('tableentry_' + id).style.backgroundColor = pale;
}

function toggleHighlighting(id) {
    if (highlightedIds[id] == 1) {
	highlightedIds[id] = 0;
	unhighlight(id);
    } else {
	highlightedIds[id] = 1;
	highlight(id, colors[colornum][0], colors[colornum][1]);
    }
    colornum = (colornum + 1) % colors.length;
}

function pasteExample() {
	$.noConflict();
    $('sequence_input').value = ">gi|48607|emb|CAA32086.1| YadA [Yersinia enterocolitica]\nMTKDFKISVSAALISALFSSPYAFADDYDGIPNLTAVQISPNADPALGLEYPVRPPVPGAGGLNASAKGI\nHSIAIGATAEAAKGAAVAVGAGSIATGVNSVAIGPLSKALGDSAVTYGAASTAQKDGVAIGARASTSDTG\nVAVGFNSKADAKNSVAIGHSSHVAANHGYSIAIGDRSKTDRENSVSIGHESLNRQLTHLAAGTKDTDAVN\nVAQLKKEIEKTQENTNKRSAELLANANAYADNKSSSVLGIANNYTDSKSAETLENARKEAFAQSKDVLNM\nAKAHSNSVARTTLETAEEHANSVARTTLETAEEHANKKSAEALASANVYADSKSSHTLKTANSYTDVTVS\nNSTKKAIRESNQYTDHKFRQLDNRLDKLDTRVDKGLASSAALNSLFQPYGVGKVNFTAGVGGYRSSQALA\nIGSGYRVNENVALKAGVAYAGSSDVMYNASFNIEW"
}
