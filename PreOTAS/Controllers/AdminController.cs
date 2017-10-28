using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data;
using System.Data.Entity;
using PreOTAS.Models;
using System.Web.Security;
using EntityFrameworkPaginate;

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
                return RedirectToAction("FilterStudent","Admin");
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
        public Page<STUDENT> FilterStudent(int PageSize, int CurrentPage, string SearchText, int SortBy, string Department)
        {
            /* 
             PageSize - no. of records
             CurrentPage - Page no.
             SearchText - Student Name only
             SortBy - drop down for section (value returned=1) sem(2) USN(3)
             Department - dropdown department name. (value returned should be dept name)
             */
            Page<STUDENT> students;
            var filters = new Filters<STUDENT>();
            filters.Add(!string.IsNullOrEmpty(SearchText), x => x.NAME.Contains(SearchText));
            filters.Add(!string.IsNullOrEmpty(SearchText), x => x.DEPT.DeptName.Equals(Department));
            var sorts = new Sorts<STUDENT>();
            sorts.Add(SortBy == 1, x => x.Section,true);
            sorts.Add(SortBy == 2, x => x.Sem,true);
            sorts.Add(SortBy == 3, x => x.USN, true);
            using (var Context = new RNSITEntities())
            {
                students = Context.STUDENTs.Paginate(CurrentPage, PageSize, sorts, filters);
            }
                return students;
        }
    }
}