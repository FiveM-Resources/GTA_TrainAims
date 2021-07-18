//--> Change your language here :
var config_language = 'en';

$(function () {
    switch (config_language) {
        case 'fr':
            $('#tr_form').text('FORMULAIRE');
            $("#tr_fName").attr("type", "Nom : ");
            $("#tr_fNameHolder").attr("placeholder", "Ce nom apparaîtra dans la liste des meilleurs scores...");
            $('#tr_validate').html('Valider');
        break;

        case 'en':
            $('#tr_form').text('FORM');
            $("#tr_fName").attr("type", "Name : ");
            $("#tr_fNameHolder").attr("placeholder", "This name will appear in the high score list...");
            $('#tr_validate').html('Validate');
        break;
    };
})