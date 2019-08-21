// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require jquery
//= require jquery_ujs
//= require_tree .

(function($) {+
    $(document).ready(function () {
        data = $.cookie("expandSection");
        if (data) {
            ids = JSON.parse(data);
            console.log(ids);
            if (ids && Array.isArray(ids)) {
                ids.forEach(id => {
                    elm = $(id);
                    $(id + "_section").toggleClass("expand");
                    elm.show(500)
                });
            }
        }
    });

    function expand(id) {
        elm = $(id);
        if (!elm) {
            return
        }
        data = $.cookie("expandSection");
        if (!data) {
            sections = []
        } else {
            sections = JSON.parse(data);
            if (!sections || !Array.isArray(sections)) {
                sections = []
            }
        }
        if (!elm.is(":hidden")) {
            idx = sections.indexOf(id);
            sections.splice(idx, 1);
            $.cookie("expandSection", JSON.stringify(sections));
            elm.hide(500);
        } else {
            sections.push(id);
            $.cookie("expandSection", JSON.stringify(sections));
            elm.show(500);
        }
        console.log(sections);
        $(id + "_section").toggleClass("expand")
    }
})(jQuery);