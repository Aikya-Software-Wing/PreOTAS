using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PreOTAS.Controllers
{
    public class TemplateController : Controller
    {
        // GET: Template
        public ActionResult GetTemplateForStudent()
        {
            FileDownload(new FileInfo(Server.MapPath("~/Templates/Student.xlsx")));
            return View();
        }

        public ActionResult GetTemplateForElective()
        {
            FileDownload(new FileInfo(Server.MapPath("~/Templates/Electives.xlsx")));
            return View();
        }

        #region Helpers
        private void FileDownload(FileInfo file)
        {
            Response.Clear();
            Response.ClearHeaders();
            Response.ClearContent();
            Response.AddHeader("Content-Disposition", "attachment; filename=" + file.Name);
            Response.AddHeader("Content-Length", file.Length.ToString());
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.Flush();
            Response.TransmitFile(file.FullName);
            Response.End();
        }
        #endregion
    }
}