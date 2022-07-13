//applying datatable
$(document).ready(function(){
  $("table[role='datatable']").each(function(){
    $(this).DataTable({
      processing: true,
      paging: false,
      info: false,
    });
  });
})

$('select').select2({
  theme: 'bootstrap4',
  allowClear: true
});


document.addEventListener('DOMContentLoaded', function() {
  flatpickr('.flatpickr');
})

$(document).on('cocoon:after-insert', (function(event) {
  flatpickr('.flatpickr');
}));

// get locale from <html lang=xx>, use in datepicker and daterangepicker
moment.locale( $('html').attr('lang') );

// daterange input
$('[name="daterange"], .daterange-picker').each(function() {
  // get format first, then all the default minimum date, start date and end date can use the same format
  // for default date format, use 'YYYY-MM-DD'(date only) or 'YYYY-MM-DD HH:mm'(for datetime)
  var $this = $(this),
      timePicker      = $this.data('timepicker') || false,
      default_format  = timePicker? 'YYYY-MM-DD HH:mm' : 'YYYY-MM-DD',
      format          = $this.data('format') || default_format,
      minDate         = $this.data('mindate') || moment(new Date('2010-01-01')).startOf('day'),
      startDate       = new Date($this.data('start') || moment().startOf('day').format(default_format)),
      endDate         = new Date($this.data('end') || moment().endOf('day').format(default_format)),
      drops       = $this.data('drops') || 'up',
      applyLabel  = $this.data('apply') || 'Submit',
      cancelLabel = $this.data('cancel') || 'Cancel',
      fromLabel   = $this.data('from') || 'From',
      toLabel     = $this.data('to') || 'To',
      separator   = $this.data('separator') || ' - '
      ;

  $this.daterangepicker(
      {
          startDate: startDate,
          endDate: endDate,
          showDropdowns: true,
          showWeekNumbers: false,
          minDate: minDate,
          timePicker: timePicker,
          timePickerIncrement: 1,
          timePicker12Hour: false,
          opens: 'left',
          drops: drops,
          buttonClasses: ['btn', 'btn-sm'],
          applyClass: 'btn-primary',
          cancelClass: 'btn-default',
          locale: {
              separator: separator,
              format: format,
              applyLabel: applyLabel,
              cancelLabel: cancelLabel,
              fromLabel: fromLabel,
              toLabel: toLabel
          }
      }
  );


});

// Ditch this method since found the official callback
// $(document).on('mouseenter', ".flatpickr", function() {
//   flatpickr('.flatpickr');
// });