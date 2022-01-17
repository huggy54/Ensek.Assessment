using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using WebApp.DAL;
using Microsoft.VisualBasic;
using System.IO;
using System.Data;
namespace WebApp.Controllers.MeterReading
{
    [RoutePrefix("api/MeterReading")]
    public class MeterReadingController : ApiController
    {

        const int METERREADING_ACCOUNTID_INDEX = 0;
        const int METERREADING_DATETIME_INDEX = 1;
        const int METERREADING_VALUE_INDEX = 2;

        [HttpOptions]
        [HttpPost]
        public IHttpActionResult processUploadedMeterReadingFile()
        {
            try
            {
                //get uploaded file contents as string
                var httpRequest = HttpContext.Current.Request;
                var postedFile = httpRequest.Files[0];
                string uploadedFileMeterReadingContents = string.Empty;

                using (StreamReader r = new StreamReader(postedFile.InputStream))
                {
                    uploadedFileMeterReadingContents = r.ReadToEnd();
                }

                //convert uploaded file contents to list
                var lstMeterReadings = uploadedFileMeterReadingContents.Split(
                    new string[] { "\r\n", "\r", "\n" },
                        StringSplitOptions.RemoveEmptyEntries
                    ).Skip(1).ToList();//skip header row

                var lstMeterReadingsLength = lstMeterReadings.Count;

                ////get invalid meterReads
                var lstRecordsWithoutValidMeterReadings = lstMeterReadings.Where(x => !Microsoft.VisualBasic.Information.IsNumeric(x.Split
                (
                    new string[] { "," },
                        StringSplitOptions.None
                 )[METERREADING_VALUE_INDEX])).ToList();

                //delete invalid meterReads
                lstMeterReadings.RemoveAll(item => lstRecordsWithoutValidMeterReadings.Any(item2 => item.Split(new string[] { "," }, StringSplitOptions.None)[METERREADING_ACCOUNTID_INDEX] ==
                item2.Split(new string[] { "," }, StringSplitOptions.None)[METERREADING_ACCOUNTID_INDEX]
                ));

                //convert list of uploaded file contents to a list of Meter_Readings objects
                var uploadMeterReadings = lstMeterReadings
                    .Select(line => line.ToString().Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                    .Select(x => new Meter_Readings
                    {
                        AccountId = Convert.ToInt32(x[METERREADING_ACCOUNTID_INDEX]),
                        MeterReadingDateTime = Convert.ToDateTime(x[METERREADING_DATETIME_INDEX]),
                        MeterReadValue = Convert.ToInt32(x[METERREADING_VALUE_INDEX])
                    })
                    .ToList();

                Ensek_TestEntities ensekDB = new Ensek_TestEntities();

                //get a list of uploaded Meter_Readings records that dont have AccountIds existing in the database
                var recordsWithoutValidAccountId = uploadMeterReadings.Where(x1 => !ensekDB.Test_Accounts.Any(x2 => x1.AccountId == x2.AccountId)).ToList();

                var duplicatedRecordsinUploadedFile = uploadMeterReadings
                 .GroupBy(x => new { x.AccountId, x.MeterReadingDateTime })
                 .Where(x => x.Count() > 1)
                 .Select(x =>new { x.Key.AccountId, x.Key.MeterReadingDateTime, Count = x.Count()})
                 .ToList();

                //make meter reading list unique (just incase there are duplicate in the uploaded file only)
                if (uploadMeterReadings.Count > 0)
                {
                    uploadMeterReadings = uploadMeterReadings.GroupBy(c => new
                    {
                        c.AccountId,
                        c.MeterReadingDateTime
                    })
                           .Select(grp => grp.First())
                           .ToList();
                }

                var duplicatesAgainstDB = uploadMeterReadings.Where(l1 => ensekDB.Meter_Readings.Any(l2 => l1.AccountId == l2.AccountId && l1.MeterReadingDateTime == l2.MeterReadingDateTime)).ToList();


                //delete from uploaded meter readings that dont have valid AccountIds that exist in db
                uploadMeterReadings.RemoveAll(item => recordsWithoutValidAccountId.Any(item2 => item.AccountId == item2.AccountId && item.MeterReadingDateTime == item2.MeterReadingDateTime));
                //delete uploaded meter readings that exists in db
                //mr.RemoveAll(l1 => ensekDB.Meter_Readings.Any(l2 => l1.AccountId == l2.AccountId && l1.MeterReadingDateTime == l2.MeterReadingDateTime));

                uploadMeterReadings.RemoveAll(l1 => duplicatesAgainstDB.Any(l2 => l1.AccountId == l2.AccountId && l1.MeterReadingDateTime == l2.MeterReadingDateTime));

                int recordsAdded = 0;

                //do insert here into db, no need to validate as already done, this is all good data
                foreach (Meter_Readings mrs in uploadMeterReadings)
                {
                    ensekDB.Meter_Readings.Add(mrs);
                    ensekDB.SaveChanges();
                    recordsAdded++;
                }
                int recordsNotAdded = (lstMeterReadingsLength - recordsAdded);
                return Json($"There were {recordsAdded} records that were successfully added. \nThere were {recordsNotAdded} records that failed to add. \n\nReport on records: \n\nThere were {duplicatesAgainstDB.Count()} records that contained duplicates against the database. \nThere were {duplicatedRecordsinUploadedFile.Count()} records that contained multiple duplicates in the uploaded file.\nThere were {recordsWithoutValidAccountId.Count()} records that failed to add to due to missing AccountIds. \nThere were {lstRecordsWithoutValidMeterReadings.Count()} records with invalid meter readings\n\n Note: A single failed record can have multiple failed conditions");
            }
            catch(Exception ex)
            {
                return Json(ex.ToString());
            }
        }
    }
}
