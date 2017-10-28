using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using PreOTAS.Models;
using System.IO;
using Excel = Microsoft.Office.Interop.Excel;
using System.Data.Entity.Validation;
using System.Data.Entity.Infrastructure;

namespace PreOTAS.Controllers
{
    [Authorize]
    public class NewElectivesTablesController : Controller
    {
        private RNSITEntities db = new RNSITEntities();

        // GET: NewElectivesTables
        public ActionResult Index()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var newElectivesTables = db.NewElectivesTables.Include(n => n.Subject).Include(n => n.STUDENT);
                return View(newElectivesTables.ToList());
            }
            else
            {
                var newElectivesTables = db.NewElectivesTables.Include(n => n.Subject).Include(n => n.STUDENT).Where(x => x.STUDENT.DeptID == department);
                return View(newElectivesTables.ToList());
            }
        }

        public ActionResult Print()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var newElectivesTables = db.NewElectivesTables.Include(n => n.Subject).Include(n => n.STUDENT);
                return View(newElectivesTables.ToList());
            }
            else
            {
                var newElectivesTables = db.NewElectivesTables.Include(n => n.Subject).Include(n => n.STUDENT).Where(x => x.STUDENT.DeptID == department);
                return View(newElectivesTables.ToList());
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
            List<ElectiveError> errorList = new List<ElectiveError>();
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
                    string SubjectCode = xlRange.Cells[i, 2].Value2.ToString();

                    NewElectivesTable table = new NewElectivesTable
                    {
                        SubCode = SubjectCode,
                        USN = Usn
                    };

                    try
                    {
                        db.NewElectivesTables.Add(table);
                        db.SaveChanges();
                    }
                    catch (DbEntityValidationException e)
                    {
                        ElectiveError error = new ElectiveError();
                        error.Usn = Usn;
                        error.SubjectCode = SubjectCode;
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
                    catch (DbUpdateException d)
                    {
                        ElectiveError error = new ElectiveError();
                        error.Usn = Usn;
                        error.SubjectCode = SubjectCode;
                        error.Errors.Add(new Error
                        {
                            AttributeName = "",
                            ErrorMessage = "Invalid Combination"
                        });
                        errorList.Add(error);
                    }
                }
            }

            return View("ElectivesError", errorList);
        }

        public ActionResult AuthorizeElectives()
        {
            return View();
        }

        public ActionResult Authorize()
        {
            string department = (string)TempData.Peek("Department");
            var students = db.NewElectivesTables.Where(x => x.STUDENT.DeptID== department).ToList();
            for (int i = 0; i < students.Count; i++)
            {
                students[i].isValid = true;
                db.NewElectivesTables.Attach(students[i]);
                db.Entry(students[i]).State = EntityState.Modified;
                db.SaveChanges();
            }
            return View();
        }

        // GET: NewElectivesTables/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            NewElectivesTable newElectivesTable = db.NewElectivesTables.Find(id);
            if (newElectivesTable == null)
            {
                return HttpNotFound();
            }
            return View(newElectivesTable);
        }

        // GET: NewElectivesTables/Create
        public ActionResult Create()
        {
            ViewBag.SubCode = new SelectList(db.Subjects, "SubCode", "SubCode");
            if (!User.IsInRole("Admin"))
            {
                string department = (string)TempData.Peek("Department");
                ViewBag.USN = new SelectList(db.STUDENTs.Where(x => x.DeptID == department), "USN", "USN");
            }
            else
            {
                ViewBag.USN = new SelectList(db.STUDENTs, "USN", "USN");
            }
            return View();
        }

        // POST: NewElectivesTables/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "USN,SubCode,id")] NewElectivesTable newElectivesTable)
        {
            if (ModelState.IsValid)
            {
                db.NewElectivesTables.Add(newElectivesTable);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            if (!User.IsInRole("Admin"))
            {
                string department = (string)TempData.Peek("Department");
                ViewBag.USN = new SelectList(db.STUDENTs.Where(x => x.DeptID == department), "USN", "USN", newElectivesTable.SubCode);
            }
            else
            {
                ViewBag.USN = new SelectList(db.STUDENTs, "USN", "USN", newElectivesTable.USN);
            }
            ViewBag.SubCode = new SelectList(db.Subjects, "SubCode", "SubName", newElectivesTable.SubCode);
            return View(newElectivesTable);
        }

        // GET: NewElectivesTables/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            NewElectivesTable newElectivesTable = db.NewElectivesTables.Find(id);
            if (newElectivesTable == null)
            {
                return HttpNotFound();
            }

            ViewBag.SubCode = new SelectList(db.Subjects, "SubCode", "SubName", newElectivesTable.SubCode);
            if (!User.IsInRole("Admin"))
            {
                string department = (string)TempData.Peek("Department");
                ViewBag.USN = new SelectList(db.STUDENTs.Where(x => x.DeptID == department), "USN", "USN", newElectivesTable.SubCode);
            }
            else
            {
                ViewBag.USN = new SelectList(db.STUDENTs, "USN", "USN", newElectivesTable.USN);
            }
            return View(newElectivesTable);
        }

        // POST: NewElectivesTables/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "USN,SubCode,id")] NewElectivesTable newElectivesTable)
        {
            if (ModelState.IsValid)
            {
                db.Entry(newElectivesTable).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.SubCode = new SelectList(db.Subjects, "SubCode", "SubName", newElectivesTable.SubCode);
            if (!User.IsInRole("Admin"))
            {
                string department = (string)TempData.Peek("Department");
                ViewBag.USN = new SelectList(db.STUDENTs.Where(x => x.DeptID == department), "USN", "USN", newElectivesTable.SubCode);
            }
            else
            {
                ViewBag.USN = new SelectList(db.STUDENTs, "USN", "USN", newElectivesTable.USN);
            }
            return View(newElectivesTable);
        }

        // GET: NewElectivesTables/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            NewElectivesTable newElectivesTable = db.NewElectivesTables.Find(id);
            if (newElectivesTable == null)
            {
                return HttpNotFound();
            }
            return View(newElectivesTable);
        }

        // POST: NewElectivesTables/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            NewElectivesTable newElectivesTable = db.NewElectivesTables.Find(id);
            db.NewElectivesTables.Remove(newElectivesTable);
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
