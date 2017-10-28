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
            string filePath = Server.MapPath("~/Templates/Student.xlsx");
            FileInfo file = new FileInfo(filePath);
            Response.Clear();
            Response.ClearHeaders();
            Response.ClearContent();
            Response.AddHeader("Content-Disposition", "attachment; filename=" + file.Name);
            Response.AddHeader("Content-Length", file.Length.ToString());
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.Flush();
            Response.TransmitFile(file.FullName);
            Response.End();
            return View();
        }
    }
}