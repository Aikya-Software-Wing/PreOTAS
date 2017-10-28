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
    [Authorize]
    public class SubjectsController : Controller
    {
        private RNSITEntities db = new RNSITEntities();

        // GET: Subjects
        public ActionResult Index()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var subjects = db.Subjects.Include(s => s.DEPT);
                return View(subjects.ToList());
            }
            else
            {
                var subjects = db.Subjects.Include(s => s.DEPT).Where(x => x.DeptId == department);
                return View(subjects.ToList());
            }
        }

        public ActionResult Print()
        {
            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var subjects = db.Subjects.Include(s => s.DEPT);
                return View(subjects.ToList());
            }
            else
            {
                var subjects = db.Subjects.Include(s => s.DEPT).Where(x => x.DeptId == department);
                return View(subjects.ToList());
            }
        }

        // GET: Subjects/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Subject subject = db.Subjects.Find(id);
            if (subject == null)
            {
                return HttpNotFound();
            }
            return View(subject);
        }

        // GET: Subjects/Create
        public ActionResult Create()
        {
            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName");
            SelectListItem yesItem = new SelectListItem
            {
                Text = "Yes",
                Value = "1"
            };
            SelectListItem noItem = new SelectListItem
            {
                Text = "No",
                Value = "0"
            };
            List<SelectListItem> electiveSelectList = new List<SelectListItem>();
            electiveSelectList.Add(yesItem);
            electiveSelectList.Add(noItem);
            ViewBag.Elective = new SelectList(electiveSelectList, "Value", "Text");
            Subject subject = new Subject();
            if(User.IsInRole("Admin"))
            {
                subject.DeptId = (string)TempData.Peek("Department");
            }
            return View(subject);
        }

        // POST: Subjects/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "SubCode,DeptId, SubName,Sem,Elective")] Subject subject)
        {
            if (ModelState.IsValid)
            {
                if (!User.IsInRole("Admin"))
                {
                    subject.DeptId = (string)TempData.Peek("Department");
                }
                db.Subjects.Add(subject);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName", subject.DeptId);
            SelectListItem yesItem = new SelectListItem
            {
                Text = "Yes",
                Value = "1"
            };
            SelectListItem noItem = new SelectListItem
            {
                Text = "No",
                Value = "0"
            };
            List<SelectListItem> electiveSelectList = new List<SelectListItem>();
            electiveSelectList.Add(yesItem);
            electiveSelectList.Add(noItem);
            ViewBag.Elective = new SelectList(electiveSelectList, "Value", "Text", subject.Elective);
            return View(subject);
        }

        // GET: Subjects/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Subject subject = db.Subjects.Find(id);
            if (subject == null)
            {
                return HttpNotFound();
            }
            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName", subject.DeptId);
            SelectListItem yesItem = new SelectListItem
            {
                Text = "Yes",
                Value = "1"
            };
            SelectListItem noItem = new SelectListItem
            {
                Text = "No",
                Value = "0"
            };
            List<SelectListItem> electiveSelectList = new List<SelectListItem>();
            electiveSelectList.Add(yesItem);
            electiveSelectList.Add(noItem);
            ViewBag.Elective = new SelectList(electiveSelectList, "Value", "Text", subject.Elective);

            if (User.IsInRole("Admin"))
            {
                subject.DeptId = (string)TempData.Peek("Department");
            }
            return View(subject);
        }

        // POST: Subjects/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "SubCode,DeptId,SubName,Sem,Elective")] Subject subject)
        {
            if (ModelState.IsValid)
            {
                if (!User.IsInRole("Admin"))
                {
                    subject.DeptId = (string)TempData.Peek("Department");
                }
                db.Entry(subject).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.DeptId = new SelectList(db.DEPTs, "DeptId", "DeptName", subject.DeptId);
            SelectListItem yesItem = new SelectListItem
            {
                Text = "Yes",
                Value = "1"
            };
            SelectListItem noItem = new SelectListItem
            {
                Text = "No",
                Value = "0"
            };
            List<SelectListItem> electiveSelectList = new List<SelectListItem>();
            electiveSelectList.Add(yesItem);
            electiveSelectList.Add(noItem);
            ViewBag.Elective = new SelectList(electiveSelectList, "Value", "Text", subject.Elective);
            return View(subject);
        }

        // GET: Subjects/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Subject subject = db.Subjects.Find(id);
            if (subject == null)
            {
                return HttpNotFound();
            }
            return View(subject);
        }

        // POST: Subjects/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            Subject subject = db.Subjects.Find(id);
            db.Subjects.Remove(subject);
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
