$(function () {

    //CLASSEMENT LIST SYSTEM NOT WORKING FOR NOW : ):
    /*
        function addRow() 
        {
            var req = new XMLHttpRequest();
            req.responseType = 'json';
            req.open('GET', "../data/dataScore.json", true);
            req.onload  = function() {
            var jsonResponse = req.response;
            for (let key in jsonResponse)
                {
                    let tableRef = document.getElementById("my-table");
                    let newRow = tableRef.insertRow(-1);
        
                    let rowName = newRow.insertCell(0);
                    let rowScore = newRow.insertCell(1);
        
                    var nameUsers = document.createTextNode(jsonResponse[key].playerName);
                    var scoreUsers = document.createTextNode(jsonResponse[key].bestScore);
        
                    rowName.appendChild(nameUsers);
                    rowScore.appendChild(scoreUsers);
        
                    console.log("c+" + jsonResponse[key]);
                }
            };
            req.send(null);
        }
        addRow()
    */

    function display(bool) 
    {
        bool ? $(".form").show() : $(".form").hide();
    }

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "enableui") {
            if (item.activate == true)
            {
                display(true)
            }else
            {
                display(false);
            }
        }
    })

    // if the person uses the escape key, it will exit the resource
    document.onkeyup = function (data) {
        if (data.which == 27) {$.post('http://GTA_TrainAims/exit', JSON.stringify({}));return}
    };
 
    //when the user clicks on the submit button, it will run
    $("#tr_validate").click(function () {
        let vfirstName = $("#tr_fNameHolder").val();
        if (!vfirstName) {$.post("http://GTA_TrainAims/error", JSON.stringify({error: "There was no value in the input field"})); return}
        $.post("http://GTA_TrainAims/main", JSON.stringify({fName: vfirstName}));
        return
    })
})