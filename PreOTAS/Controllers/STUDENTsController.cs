using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using PreOTAS.Models;
using Excel = Microsoft.Office.Interop.Excel;
using System.IO;
using System.Configuration;
using System.Data.Entity.Validation;
using System.Data.Entity.Infrastructure;

namespace PreOTAS.Controllers
{
    public class STUDENTsController : Controller
    {
        private RNSITEntities db = new RNSITEntities();

        // GET: STUDENTs
        public ActionResult Index()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var sTUDENTs = db.STUDENTs.Include(s => s.DEPT).Include(s => s.Valid);
                return View(sTUDENTs.ToList());
            }
            else
            {
                var sTUDENTs = db.STUDENTs.Include(s => s.DEPT).Include(s => s.Valid).Where(x => x.DeptID == department);
                return View(sTUDENTs.ToList());
            }
        }

        public ActionResult BulkUpload()
        {
            return View();
        }

        [HttpPost]
        public ActionResult BulkUpload(HttpPostedFileBase postedFile)
        {
            string filePath = string.Empty;
            List<StudentError> errorList = new List<StudentError>();
            if (postedFile != null)
            {
                string path = Server.MapPath("~/Uploads/");
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }

                filePath = path + Path.GetFileName(postedFile.FileName) + DateTime.Now.Ticks;
                string extension = Path.GetExtension(postedFile.FileName);
                postedFile.SaveAs(filePath);

                Excel.Application xlApp = new Excel.Application();
                Excel.Workbook xlWorkbook = xlApp.Workbooks.Open(filePath);
                Excel._Worksheet xlWorksheet = xlWorkbook.Sheets[1];
                Excel.Range xlRange = xlWorksheet.UsedRange;

                int rowCount = xlRange.Rows.Count;

                for (int i = 2; i <= rowCount; i++)
                {
                    string Usn = xlRange.Cells[i, 1].Value2.ToString();
                    string Name = xlRange.Cells[i, 2].Value2.ToString();
                    int Sem = int.Parse(xlRange.Cells[i, 3].Value2.ToString());
                    string Section = xlRange.Cells[i, 4].Value2.ToString();
                    string department = (string)TempData.Peek("Department");

                    STUDENT student = new STUDENT
                    {
                        DeptID = department,
                        Section = Section.Trim(),
                        Sem = Sem,
                        NAME = Name,
                        USN = Usn
                    };

                    try
                    {
                        db.STUDENTs.Add(student);
                        db.SaveChanges();
                    }
                    catch (DbEntityValidationException e)
                    {
                        StudentError error = new StudentError();
                        error.Usn = Usn;
                        foreach (var eve in e.EntityValidationErrors)
                        {
                            foreach (var ve in eve.ValidationErrors)
                            {
                                error.Errors.Add(new Error
                                {
                                    AttributeName = ve.PropertyName,
                                    ErrorMessage = ve.ErrorMessage
                                });
                            }
                        }
                        errorList.Add(error);
                    }
                    catch(DbUpdateException d)
                    {
                        StudentError error = new StudentError();
                        error.Usn = Usn;
                        error.Errors.Add(new Error
                        {
                            AttributeName = "Usn",
                            ErrorMessage = "Usn is already taken"
                        });
                        errorList.Add(error);
                    }
                }
            }

            return View("StudentErrors", errorList);
        }

        public ActionResult Print()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var sTUDENTs = db.STUDENTs.Include(s => s.DEPT).Include(s => s.Valid);
                return View(sTUDENTs.ToList());
            }
            else
            {
                var sTUDENTs = db.STUDENTs.Include(s => s.DEPT).Include(s => s.Valid).Where(x => x.DeptID == department);
                return View(sTUDENTs.ToList());
            }
        }

        public ActionResult AuthorizeStudents()
        {
            return View();
        }

        public ActionResult Authorize()
        {
            string department = (string)TempData.Peek("Department");
            var students = db.STUDENTs.Where(x => x.DeptID == department).ToList();
            for (int i = 0; i < students.Count; i++)
            {
                students[i].isVallid = true;
                students[i].Section = students[i].Section.Trim();
                db.STUDENTs.Attach(students[i]);
                db.Entry(students[i]).State = EntityState.Modified;
                db.SaveChanges();
            }
            return View();
        }

        // GET: STUDENTs/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            STUDENT sTUDENT = db.STUDENTs.Find(id);
            if (sTUDENT == null)
            {
                return HttpNotFound();
            }
            return View(sTUDENT);
        }

        // GET: STUDENTs/Create
        public ActionResult Create()
        {
            ViewBag.DeptID = new SelectList(db.DEPTs, "DeptId", "DeptName");
            ViewBag.USN = new SelectList(db.ValidS, "USN", "PASSGEN");
            STUDENT student = new STUDENT();
            if (User.IsInRole("Admin"))
            {
                student.DeptID = (string)TempData.Peek("Department");
            }
            return View(student);
        }

        // POST: STUDENTs/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "USN,NAME,DOB,FATHERNAME,MOTHERNAME,GUARDIANNAME,PERM_ADDRESS,LOC_ADDRESS,MOBILE,PRIMARY_CONTACT,DeptID,Sem,Section,EMail,SSLC,PUC,Batch")] STUDENT sTUDENT)
        {
            if (ModelState.IsValid)
            {
                if (!User.IsInRole("Admin"))
                {
                    sTUDENT.DeptID = (string)TempData.Peek("Department");
                }
                db.STUDENTs.Add(sTUDENT);
                db.SaveChanges();
                TempData["StudentUSN"] = sTUDENT.USN;
                return RedirectToAction("Index");
            }

            ViewBag.DeptID = new SelectList(db.DEPTs, "DeptId", "DeptName", sTUDENT.DeptID);
            ViewBag.USN = new SelectList(db.ValidS, "USN", "PASSGEN", sTUDENT.USN);
            return View(sTUDENT);
        }

        // GET: STUDENTs/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            STUDENT sTUDENT = db.STUDENTs.Find(id);
            if (sTUDENT == null)
            {
                return HttpNotFound();
            }
            ViewBag.DeptID = new SelectList(db.DEPTs, "DeptId", "DeptName", sTUDENT.DeptID);
            ViewBag.USN = new SelectList(db.ValidS, "USN", "PASSGEN", sTUDENT.USN);
            if (User.IsInRole("Admin"))
            {
                sTUDENT.DeptID = (string)TempData.Peek("Department");
            }
            return View(sTUDENT);
        }

        // POST: STUDENTs/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "USN,NAME,DOB,FATHERNAME,MOTHERNAME,GUARDIANNAME,PERM_ADDRESS,LOC_ADDRESS,MOBILE,PRIMARY_CONTACT,DeptID,Sem,Section,EMail,SSLC,PUC,Batch")] STUDENT sTUDENT)
        {
            if (ModelState.IsValid)
            {
                if (!User.IsInRole("Admin"))
                {
                    sTUDENT.DeptID = (string)TempData.Peek("Department");
                }
                db.Entry(sTUDENT).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.DeptID = new SelectList(db.DEPTs, "DeptId", "DeptName", sTUDENT.DeptID);
            ViewBag.USN = new SelectList(db.ValidS, "USN", "PASSGEN", sTUDENT.USN);
            return View(sTUDENT);
        }

        // GET: STUDENTs/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            STUDENT sTUDENT = db.STUDENTs.Find(id);
            if (sTUDENT == null)
            {
                return HttpNotFound();
            }
            return View(sTUDENT);
        }

        // POST: STUDENTs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            STUDENT sTUDENT = db.STUDENTs.Find(id);
            db.STUDENTs.Remove(sTUDENT);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
