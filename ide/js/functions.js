//var jQuery = require("jquery");
(function($){
	$.fn.form2JSON = function() {
		return this.serializeArray().reduce(function(a, x) { a[x.name] = x.value; return a; }, {});
	};
	$.fn.formFromJSON = function(data) {
		var frm = this;
		$.each(data, function(key, value) {
			var ctrl = $('[name='+key+']', frm);
			if (ctrl) switch(ctrl.prop("type")) { 
				case "radio": case "checkbox":   
					ctrl.each(function() {
						if($(this).attr('value') == value) $(this).attr("checked",value);
					});   
					break;  
				default:
					ctrl.val(value); 
			}  
		});
	};
})(jQuery);