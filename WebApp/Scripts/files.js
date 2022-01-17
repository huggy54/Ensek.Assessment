function uploadFiles() {
    var input = document.getElementById('fileSelect');   
    var files = input.files;
    if (!files.length)
    {
        alert("You must select a file to upload to proceed");
        return;
    }

    var formData = new FormData();

    for (var i = 0; i != files.length; i++)
    {
        formData.append("files", files[i]);
    }

    $.blockUI({ css: { border: 'none', backgroundColor: 'transparent', '-webkit-border-radius': '5px', '-moz-border-radius': '5px', opacity: .5 }, message: "<div class='lds-dual-ring'>Loading</div>" });

    $.ajax(
        {
            url: "/api/MeterReading/processUploadedMeterReadingFile",
            data: formData,
            processData: false,
            contentType: false,
            type: "POST",
            success: function (data) {
            $.unblockUI();
            alert("Files Uploaded!\n" + data);
                },
            error: function () {
                $.unblockUI();
                alert('Error occured');
            }
        });
}