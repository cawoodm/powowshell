/*var jQuery = $ = require("jquery");
require("jquery-ui-bundle");
require("bootstrap3");*/

// Our pipeline data model
var pw = {
	pipeline: {
		steps: [
			{"id": "A1", "name": "Read CSV", "component": "ReadFile"},
			{"id": "B1", "name": "Convert to JSON", "component": "Data2JSON"},
			{"id": "B2", "name": "Fill Template", "component": "JavaScript"},
			{"id": "C1", "name": "Filter", "component": "Filter"},
			{"id": "C2", "name": "Send Email", "component": "JavaScript"},
			{"id": "C3", "name": "Run Script", "component": "JavaScript"},
			{"id": "D1", "name": "Save to Database", "component": "DatabaseWrite"},
		]
	}
};
// Setup UI, dialogs, dragging and matrix of spacers
$( function() {

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

	showPipeline(pw.pipeline)
	
	// Create placeholder "spacers" in the matrix
	spacers()
});
function showPipeline(pipeline) {
	pipeline.steps.forEach((step) => {
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
	data.name=data.name||data.component;
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
	// TODO: Update pw.pipeline.steps
	$el.find('.stepHead').text(data.name);	
	pw.dialog.modal('hide');
}
// A Component or Step is dropped -> place or move
function dropStep(event, ui) {
	var src = ui.draggable[0];
	var dest = event.target.parentElement;
	let col = dest.id.substr(dest.id.length-1);
	var el, data, fromComponent=false;
	if (src.id.match(/^comp_/)) {
		// Component (from library) is dropped -> Generate a step
		data = JSON.parse(src.getAttribute("data"));
		el = comp2Step(data);
		setStep(col, null, data)
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
function setStep(col, row, data) {
	dest = $('#col_'+col)[0];
	let el = comp2Step(data);
	el.setAttribute("data", JSON.stringify(data));
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
	let icon = mapIcons[data.component]||"edit";
	$(i).addClass("icon glyphicon glyphicon-"+icon);
	i.innerText = data.component;
	//if (data.type == "destination" || data.type == "transform") {i2 = document.createElement('span');$(i2).addClass("glyphicon-chevron-right");	el.appendChild(i2);	}
	$(el).find('.stepHead').text(data.name||data.component);
	$(el).find('.stepBody').append(i);
	//if (data.type == "source" || data.type == "transform") {i1 = document.createElement('span');$(i1).addClass("glyphicon-chevron-right");el.appendChild(i1);	}
	$(el).removeClass('pw_comp')
	$(el).addClass('pw_step')
	$(el).addClass('pw_box')
	return el;
}
