var pw = {
	pipeline: {
		steps: {
			
		}
	}
};
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
	
	// Create placeholder "spacers" in the matrix
	spacers()
});
function saveStep(frm) {
	var data = frm.form2JSON();
	pw.formData.name = data.name;
	var $el = $('#step_'+data.step)
	$el.attr('data', JSON.stringify(pw.formData))
	// TODO: Update pw.pipeline.steps
	$el.find('.stepHead').text(data.name);	
	pw.dialog.modal('hide');
}
function dropStep(event, ui) {
	var src = ui.draggable[0];
	var dest = event.target.parentElement;
	var el, data, fromComponent=false;
	if (src.id.match(/^comp_/)) {
		// Component
		data = JSON.parse(src.getAttribute("data"));
		el = comp2Step(data);
		fromComponent = true;
	} else {
		// STEP: Move, don't copy steps
		src.remove();
		el = $(src).clone()[0];
		data = JSON.parse(src.getAttribute("data"));
	}
	el.setAttribute("data", JSON.stringify(data));
	first = 1;
	el.id = dest.id.replace('col_', 'step_');
	el.id += dest.childNodes.length;
	dest.appendChild(el);
	$(el).draggable({cancel:false, helper: "clone"});
	spacers()
	$(".pw_step").on("click", function(e) {
		data = JSON.parse(el.getAttribute("data"));
		data.step = el.id.substring(5);
		data.name=data.name||data.component;
		pw.form.formFromJSON(data);
		pw.formData = data;
		pw.dialog.modal("show");
	});
	if (fromComponent) $(el).trigger("click");
	//TODO: Add new columns if required
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
	$(i).addClass("icon glyphicon glyphicon-"+data.icon);
	i.innerText = data.component;
	//if (data.type == "destination" || data.type == "transform") {i2 = document.createElement('span');$(i2).addClass("glyphicon-chevron-right");	el.appendChild(i2);	}
	$(el).find('.stepHead').text(data.component);
	$(el).find('.stepBody')[0].append(i);
	//if (data.type == "source" || data.type == "transform") {i1 = document.createElement('span');$(i1).addClass("glyphicon-chevron-right");el.appendChild(i1);	}
	$(el).removeClass('pw_comp')
	$(el).addClass('pw_step')
	$(el).addClass('pw_box')
	return el;
}
