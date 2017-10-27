using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using PreOTAS.Models;

namespace PreOTAS.Controllers
{
    public class TeachersController : Controller
    {
        private RNSITEntities db = new RNSITEntities();

        // GET: Teachers
        public ActionResult Index()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var teachers = db.Teachers.Include(t => t.DEPT);
                return View(teachers.ToList());
            }
            else
            {
                var teachers = db.Teachers.Include(t => t.DEPT).Where(x => x.DeptId == department);
                return View(teachers.ToList());
            }
        }

        public ActionResult Print()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var teachers = db.Teachers.Include(t => t.DEPT);
                return View(teachers.ToList());
            }
            else
            {
                var teachers = db.Teachers.Include(t => t.DEPT).Where(x => x.DeptId == department);
                return View(teachers.ToList());
            }
        }

        // GET: Teachers/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Teacher teacher = db.Teachers.Find(id);
            if (teacher == null)
            {
                return HttpNotFound();
            }
            return View(teacher);
        }

        // GET: Teachers/Create
        public ActionResult Create()
        {
            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName");
            ViewBag.Designation = new SelectList(new List<SelectListItem>
            {
                new SelectListItem { Text = "HoD", Value = "Hod" },
                new SelectListItem { Text = "Professor", Value = "Professor" },
                new SelectListItem { Text = "Associate Professor", Value = "Associate Professor" },
                new SelectListItem { Text = "Assistant Professor", Value = "Assistant Professor" }
            }, "Value", "Text");
            Teacher teacher = new Teacher();
            if (!User.IsInRole("Admin"))
            {
                teacher.DeptId = (string)TempData.Peek("Department");
            }
            return View(teacher);
        }

        // POST: Teachers/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "TID,DeptId,TeacherName,Designation,E_mail,password")] Teacher teacher)
        {
            if (ModelState.IsValid)
            {
                int numberOfTeachers = db.Teachers.Where(x => x.DeptId == teacher.DeptId).ToList().Count;
                teacher.TID = teacher.DeptId.Trim() + "" + (numberOfTeachers + 1);
                db.Teachers.Add(teacher);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName", teacher.DeptId);
            ViewBag.Designation = new SelectList(new List<SelectListItem>
            {
                new SelectListItem { Text = "HoD", Value = "Hod" },
                new SelectListItem { Text = "Professor", Value = "Professor" },
                new SelectListItem { Text = "Associate Professor", Value = "Associate Professor" },
                new SelectListItem { Text = "Assistant Professor", Value = "Assistant Professor" }
            }, "Value", "Text", teacher.Designation);
            return View(teacher);
        }

        // GET: Teachers/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Teacher teacher = db.Teachers.Find(id);
            if (teacher == null)
            {
                return HttpNotFound();
            }
            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName", teacher.DeptId);
            ViewBag.Designation = new SelectList(new List<SelectListItem>
            {
                new SelectListItem { Text = "HoD", Value = "Hod" },
                new SelectListItem { Text = "Professor", Value = "Professor" },
                new SelectListItem { Text = "Associate Professor", Value = "Associate Professor" },
                new SelectListItem { Text = "Assistant Professor", Value = "Assistant Professor" }
            }, "Value", "Text", teacher.Designation);
            return View(teacher);
        }

        // POST: Teachers/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "TID,TeacherName,Designation,E_mail,password")] Teacher teacher)
        {
            if (ModelState.IsValid)
            {
                if (!User.IsInRole("Admin"))
                {
                    teacher.DeptId = (string)TempData.Peek("Department");
                }
                db.Entry(teacher).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName", teacher.DeptId);
            ViewBag.Designation = new SelectList(new List<SelectListItem>
            {
                new SelectListItem { Text = "HoD", Value = "Hod" },
                new SelectListItem { Text = "Professor", Value = "Professor" },
                new SelectListItem { Text = "Associate Professor", Value = "Associate Professor" },
                new SelectListItem { Text = "Assistant Professor", Value = "Assistant Professor" }
            }, "Value", "Text", teacher.Designation);
            return View(teacher);
        }

        // GET: Teachers/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Teacher teacher = db.Teachers.Find(id);
            if (teacher == null)
            {
                return HttpNotFound();
            }
            return View(teacher);
        }

        // POST: Teachers/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            Teacher teacher = db.Teachers.Find(id);
            db.Teachers.Remove(teacher);
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
