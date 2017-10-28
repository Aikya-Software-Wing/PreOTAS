using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data;
using System.Data.Entity;
using PreOTAS.Models;
using System.Web.Security;

namespace PreOTAS.Controllers
{
    public class AdminController : Controller
    {
        private RNSITEntities db = new RNSITEntities();
        // GET: Admin
        public ActionResult Generate()
        {
            if (User.IsInRole("Admin"))
            {
                List<STUDENT> students = db.STUDENTs.ToList();
                foreach (var student in students)
                {
                    if (student.Password == null )
                    {
                        student.Section = student.Section.Trim();
                        student.Password = Membership.GeneratePassword(6,1);
                        db.STUDENTs.Attach(student);
                        db.Entry(student).State = EntityState.Modified;
                        db.SaveChanges();
                    }
                }
                return RedirectToAction("Index","Admin");
            }
            else
                return RedirectToAction("Index", "Home");
        }
        public ActionResult Index()
        {
            if (User.IsInRole("Admin"))
            {
                return View(db.STUDENTs.ToList().OrderBy(x => x.USN));
            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
        }
    }
}