/*var jQuery = $ = require("jquery");
require("jquery-ui-bundle");
require("bootstrap3");*/

// Our global application
var pw = {};

// Load components list
$.getJSON('./components.json').done((data)=>{pw.components=data}).fail((jqxhr, textStatus, error )=>{var err = textStatus + ", " + error;console.log(err);alert("Error loading pipeline1.json!")});

// Our pipeline data model

pipelineManager.reset();
$.getJSON('../examples/pipeline1/pipeline.json').done((data)=>{
	pw.pipeline1=data;
	pipelineManager.import(pw.pipeline1);
	showSteps(pipelineManager.getSteps());
	spacers();
}).fail((jqxhr, textStatus, error )=>{var err = textStatus + ", " + error;console.log(err);alert("Error loading pipeline1.json!")});
//testPipeline = { "id": "pipeline1", "name": "Send mail to young voters", "description": "Read voters.txt, get all voters under 21yrs of age and send them an email", "parameters": { "DataSource": { "default": ".\\data\\voters.txt", "type": "string" }, "p2": { "default": "{Get-Date}" } }, "globals": { "foo": "bar" }, "checks": { "run": "some checks that we have all we need (e.g. ./data/voters.txt) to run?" }, "input": {}, "output": {}, "steps": [ { "id":"A1", "name":"Read Voters File", "reference":"../components/ReadFile.ps1", "input":"", "parameters": { "Path": "{$PipelineParams.DataSource}" } }, { "id":"B1", "name":"Convert2JSON", "reference":"../components/CSV2JSON.ps1", "input": "A", "parameters": { "Delimiter": "|", "Header": "{\"name\", \"age\", \"email\", \"source\"}" } }, { "id":"C1", "name":"Select Name and Email", "reference":"../components/SelectFields.ps1", "input": "B", "parameters": { "Fields": "{\"name\", \"age\", \"email\"}" } } ] };

// Setup UI, dialogs, dragging and matrix of spacers
$(function() {

	// Fix jQuery-UI/Bootstrap conflicts
	//$.fn.bootstrapBtn = $.fn.button.noConflict();

	// Create Modify Step Dialog
	pw.dialog = $("#dialog-form").modal({
		keyboard: true,
		backdrop: 'static',
		show: false
	}).hide();
	pw.form = pw.dialog.find("form").submit(function( event ) {
		event.preventDefault();
		saveStep(pw.form);
	});
	
	// Make all components draggable
	$(".pw_comp").draggable({helper: "clone", zIndex : 10});

	// Create placeholder "spacers" in the matrix
	spacers()
});
function showSteps(steps) {
	steps.forEach((step) => {
		setStep(step.id.substr(0, 1), null, step)
	});
}
let mapIcons = {
	"Filter": "filter",
	"JavaScript": "edit",
	"Data2JSON": "random",
	"Sort": "sort-by-alphabet",
	"ReadFile": "open-file",
	"WriteFile": "save-file",
	"DatabaseSelect": "lock",
	"DatabaseWrite": "lock",
}
// A Step is clicked for editing -> show form
function editStep(el) {
	data = JSON.parse(el.getAttribute("data"));
	data.step = el.id.substring(5);
	data.name=data.name||data.reference.match(/([a-z]+).ps1/i)[1];
	pw.form.formFromJSON(data);
	pw.formData = data;
	pw.dialog.modal("show");
}
// A Step is closed -> save changes
function saveStep(frm) {
	var data = frm.form2JSON();
	pw.formData.name = data.name;
	var $el = $('#step_'+data.step)
	let dataJson = JSON.stringify(pw.formData)
	dp("data saved", data)
	$el.attr('data', dataJson);
	// TODO: Update pipelineManager.updateStep()
	$el.find('.stepHead').text(data.name);	
	pw.dialog.modal('hide');
}
// A Component or Step is dropped -> place or move
function dropStep(event, ui) {
	var src = ui.draggable[0];
	var dest = event.target.parentElement;
	let col = dest.id.substr(dest.id.length-1);
	var el, data, step, fromComponent=false;
	if (src.id.match(/^comp_/)) {
		// Component (from library) is dropped -> Generate a step
		data = JSON.parse(src.getAttribute("data"));
		step = pipelineManager.addComponent(col, null, data);
		el = comp2Step(step);
		setStep(col, null, step)
		$(el).trigger("click");
		return
	} else {
		// A Step is dropped -> move it
		src.remove();
		el = $(src).clone()[0];
		data = JSON.parse(src.getAttribute("data"));
		//setStep(col, null, data)
	}
	el.setAttribute("data", JSON.stringify(data));
	first = 1;
	el.id = dest.id.replace('col_', 'step_');
	el.id += dest.childNodes.length;
	dest.appendChild(el);
	$(el).draggable({cancel:false, helper: "clone"});
	spacers()
	$(".pw_step").on("click", () => {editStep(el)});
	//TODO: Add new columns if required
}
function setStep(col, row, step) {
	dest = $('#col_'+col)[0];
	let el = comp2Step(step);
	el.setAttribute("data", JSON.stringify(step));
	el.id = dest.id.replace('col_', 'step_');
	el.id += dest.childNodes.length;
	dest.appendChild(el);
	$(el).draggable({cancel:false, helper: "clone"});
	spacers()
	$(".pw_step").on("click", () => {editStep(el)});
}
var dp = console.log;
function spacers() {
	$('.drophere').each(function(i, el) {
		$(el).find('.spacer').remove();
		$(el).append('<div class="spacer pw_box">...<div>');
	});
	
	// Allow drag to matrix
	$(".spacer").droppable({
		accept: ".pw_comp,.pw_step",
		classes: {
			"ui-droppable-active": "ui-state-default"
		},
		drop: dropStep
	});
}
function comp2Step(data) {
	// Make a Step from a Component
	var ht = $('#stepTemplate1').html();
	var el = $.parseHTML(ht)[0];
	var i = document.createElement('span');
	let icon = mapIcons[data.reference]||"edit";
	$(i).addClass("icon glyphicon glyphicon-"+icon);
	i.innerText = data.reference.match(/([a-z]+).ps1/i)[1];
	//if (data.type == "destination" || data.type == "transform") {i2 = document.createElement('span');$(i2).addClass("glyphicon-chevron-right");	el.appendChild(i2);	}
	$(el).find('.stepHead').text(data.id + ': ' + data.name||data.reference);
	$(el).find('.stepBody').append(i);
	i = document.createElement('div');
	if (data.input) {
		i.innerText="Input:" + data.input;
		$(el).find('.stepBody').append(i);
	}
	//if (data.type == "source" || data.type == "transform") {i1 = document.createElement('span');$(i1).addClass("glyphicon-chevron-right");el.appendChild(i1);	}
	$(el).removeClass('pw_comp')
	$(el).addClass('pw_step')
	$(el).addClass('pw_box')
	return el;
}
