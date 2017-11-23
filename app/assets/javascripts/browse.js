
$(document).ready(function(){
    $.getJSON("discipline_hierarchy.json", function(json) {
        $('#tree').treeview({
                data: json['all'],
                expandIcon: "glyphicon-none",
                collapseIcon: "glyphicon-none",
                // expandIcon: null,
                // collapseIcon: null,
                showIcon:false,
                enableLinks: true
               
            });
        $('#tree').treeview('collapseAll', { silent: true });
        console.log(json['all']);
       $('#tree').on('nodeSelected', function(event, data){
            // $('#results').replaceWith("<%= escape_javascript render(:partial => '/doc/results' =%>");
            $.get("results?kw="+data.keyword, function(d){

                var my_div = $('#result_table', $(d));                
                $('#results').html(my_div);
            });
       });


    });
   
});
