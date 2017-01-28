import "phoenix_html"

var chooseExistingId = '#choose-existing';
var createNewId = '#create-new';

function toggleVisibleFormGroup(visibleId, hiddenId) {
  if (!$(this).hasClass('active')) {
    $(this).toggleClass('active');
    $(hiddenId + ' a').removeClass('active');
    $(visibleId + ' .form-group').toggle();
    $(visibleId + ' .form-error').toggle();
    $(hiddenId + ' .form-group').hide();
    $(hiddenId + ' .form-error').hide();
  }
}

$('#choose-existing .form-group').hide();
$('#choose-existing .form-error').hide();
$('#create-new .form-group').hide();
$('#create-new .form-error').hide();

$('#choose-existing a').on('click', function() {
  if (!$(this).hasClass('active')) {
    $(this).toggleClass('active');
    toggleVisibleFormGroup(chooseExistingId, createNewId);
  }
});

$('#create-new a').on('click', function() {
  if (!$(this).hasClass('active')) {
    $(this).toggleClass('active');
    toggleVisibleFormGroup(createNewId, chooseExistingId);
  }
});


