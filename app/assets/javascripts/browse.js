
$(document).ready(function(){
    $.getJSON("/discipline_hierarchy.json", function(json) {
        $('#tree').treeview({
                data: json['all'],
                expandIcon: "glyphicon glyphicon-menu-right",
                collapseIcon: "glyphicon glyphicon-menu-down"
                // expandIcon: "glyphicon glyphicon-arrow-right",
                // collapseIcon: "glyphicon glyphicon-arrow-down"
            });
        $('#tree').treeview('collapseAll', { silent: true });
    });
});
