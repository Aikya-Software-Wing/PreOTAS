using PreOTAS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OTASNewLoginTrial.Controllers
{
    [Authorize]

    public class AddTeacherController : Controller
    {
        //
        // GET: /Admin/
        RNSITEntities db = new RNSITEntities();
        public List<SelectListItem> GetDepat()
        {
            List<SelectListItem> Dep = new List<SelectListItem>();

            //Select Department list on basis of the Sem
            foreach (DEPT depart in db.DEPTs.ToList())
            {
                SelectListItem su = new SelectListItem
                {
                    Text = depart.DeptId.ToString().Trim(),
                    Value = depart.DeptId.ToString().Trim()
                };
                Dep.Add(su);
            }
            Dep = Dep.GroupBy(x => x.Text).Select(x => x.First()).ToList();

            Dep.Add(new SelectListItem { Text = "Select Department", Value = "0", Selected = true });
            return Dep;
        }
        public JsonResult GetSem(string name)
        {
            var db = new RNSITEntities();
            //name = ((string)TempData.Peek("Department")).ToUpper();

            List<SelectListItem> Semester = new List<SelectListItem>();
            List<spGetSem_Result> l = db.spGetSem(name).ToList();
            foreach (var s in l)
            {
                Semester.Add(new SelectListItem { Text = s.ID.ToString().Trim(), Value = s.Value.ToString().Trim() });
            }

            return Json(Semester, JsonRequestBehavior.AllowGet);

        }

        public ActionResult ADD()
        {
            var a = (IndexVM)TempData["list"];
            foreach (var i in a.ListofIndex)
            {
                i.SubCombId = Generate_SubcombId(i.Sem);
                try
                {
                    i.count = db.SubCombs.OrderByDescending(x => x.Count).Select(l => l.Count).First() + 1;
                }
                catch (Exception)
                {
                    i.count = 1;
                }
                SubComb add1 = new SubComb();
                add1.DeptId = i.Deptlist;
                var b = db.Subjects.Find(i.subcode);

                if (b.Elective == 0)
                    add1.Elective = false;
                else
                    add1.Elective = true;
                add1.Count = i.count;
                add1.CombId = i.SubCombId;
                add1.TID = i.TID;
                add1.SubCode = i.subcode;
                add1.Sem = i.Sem;
                add1.Section = i.sec;
                add1.CGPA = null;
                add1.Percentile = null;
                add1.ClassesHeld = 0;
                db.SubCombs.Add(add1);
                db.SaveChanges();
            }

            return View();
        }
        public ActionResult SemesterList()
        {
            var db = new RNSITEntities();
            string DeptId = ((string)TempData.Peek("Department")).ToUpper();

            IQueryable Sem = db.spGetSem(DeptId).AsQueryable();

            if (HttpContext.Request.IsAjaxRequest())
                return Json(new SelectList(Sem, "ID", "Value"), JsonRequestBehavior.AllowGet);

            return View(Sem);
        }

        public ActionResult SectionList(string Sem)
        {
            var db = new RNSITEntities();
            string DeptId = ((string)TempData.Peek("Department")).ToUpper();
            IQueryable Sec = db.spGetSection(DeptId, int.Parse(Sem)).AsQueryable();

            if (HttpContext.Request.IsAjaxRequest())
                return Json(new SelectList(Sec, "ID", "Value"), JsonRequestBehavior.AllowGet);

            return View(Sec);
        }
        public List<SelectListItem> GetSectionList(string DeptList, int Sem)
        {
            List<SelectListItem> Section = new List<SelectListItem>();
            List<spGetSection_Result> l = db.spGetSection(DeptList.Trim(), Sem).ToList();
            foreach (var s in l)
            {
                Section.Add(new SelectListItem { Text = s.ID.ToString().Trim(), Value = s.Value.ToString().Trim() });
            }
            return Section;
        }
        public List<SelectListItem> GetSubDept(int Sem)
        {
            List<SelectListItem> Dl = new List<SelectListItem>();

            //Select Department list on basis of the Sem
            foreach (Subject sub in db.Subjects.Where(x => x.Sem == Sem).ToList())
            {
                SelectListItem su = new SelectListItem
                {
                    Text = sub.DeptId.ToString().Trim(),
                    Value = sub.DeptId.ToString().Trim()
                };
                Dl.Add(su);
            }
            Dl = Dl.GroupBy(x => x.Text).Select(x => x.First()).ToList();
            return Dl;
        }
        public ActionResult ViewClassDetails()
        {
            return View();
        }
        [HttpPost]
        public ActionResult ViewClassDetails(string Semester, string Section)
        {
            if (Semester == null || Section == null || Semester == "0" || Section == "0")
            {
                ModelState.AddModelError(string.Empty, "Please provide all the details");
                return View();
            }
            var db = new RNSITEntities();
            string Department = ((string)TempData.Peek("Department")).ToUpper();

            StudentTeacherRetrival studentDetails = new StudentTeacherRetrival();
            studentDetails.USN = db.spGetStudentsInClass(Department, int.Parse(Semester), Section).First().USN;
            var details = db.GetTeacherDetailsByUSN(studentDetails.USN);
            Session["Check"] = true;
            return View("StudentDetailsFirstPage");
        }
        public ActionResult Index()
        {
            TempData["list"] = null;
            IndexVM dept = new IndexVM();
            dept.DepartmentList = GetDepat();
            dept.TeacherDetail = GetDepat();
            TempData["list"] = dept;
            return View(dept);
        }
        [HttpPost]
        public ActionResult Index(IndexVM a)
        {


            var b = (IndexVM)TempData["list"];
            if (b.ListofIndex.Count == 0)
            {
                b.SectionList = GetSectionList(a.Deptlist, a.Sem);
                b.Deptlist = a.Deptlist;
                //b.SubjectDeptList = GetSubDept(a.Sem);
                //get subject list depending upon Sem and Department
                var samp = db.Subjects.Where(x => x.Sem == a.Sem).ToList();
                var late = db.Subjects.Where(x => x.Sem == a.Sem).Select(x => new { Text = x.DeptId, Value = x.DeptId }).ToList();
                late = late.GroupBy(x => x.Text).Select(x => x.First()).ToList();

                b.SubjectDeptList = new SelectList(late, "Value", "Text").ToList();
                b.SubjectDeptList.Add(new SelectListItem { Text = "Select Subject Department", Value = "0", Selected = true });
                b.Semester = Semmanu(b.Deptlist);
                b.sec = a.sec;
                b.Sem = a.Sem;



            }
            if (ModelState.IsValid)
            {

                a.TeacherName = db.Teachers.Find(a.TID).TeacherName;
                a.SubjectName = db.Subjects.Find(a.subcode).SubName;
                int l = 1;
                //add the element to the list
                foreach (var i in b.ListofIndex)
                {
                    if (i.sec == a.sec && i.Sem == a.Sem && i.subcode == a.subcode && i.TID == a.TID)
                    {
                        l = 2;
                        break;
                    }
                }
                if (l != 2)
                {
                    b.ListofIndex.Add(a);
                    b.subcode = "0";
                    b.TID = "0";
                    b.SDept = "0";
                    b.Tdept = "0";
                }
            }
            else
            {
                //for listing copy content of b to a i.e. ListOfIndex value
                b.Tdept = a.Tdept;
                b.SDept = a.Tdept;
                b.TID = a.TID;
                b.sec = a.sec;
                b.subcode = a.subcode;
                ModelState.AddModelError(String.Empty, "PLEASE ENTER ALL THE FIELD");

            }
            b.sec = a.sec;
            TempData["list"] = b;



            return View(b);
        }
        public JsonResult GetTeacher(string Tdept)
        {
            List<SelectListItem> TeacherList = new List<SelectListItem>();
            //Teacher Name list based on Department
            foreach (Teacher tech in db.Teachers.Where(x => x.DeptId == Tdept).ToList())
            {
                SelectListItem su = new SelectListItem
                {
                    Text = tech.TeacherName.ToString(),
                    Value = tech.TID.ToString()

                };
                TeacherList.Add(su);
            }
            return Json(TeacherList, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetSubject(String Subdept, int sem)
        {
            List<SelectListItem> lk = new List<SelectListItem>();
            foreach (Subject sub in db.Subjects.Where(x => x.Sem == sem && x.DeptId == Subdept).ToList())
            {
                SelectListItem su = new SelectListItem
                {
                    Text = sub.SubName.ToString() + "(" + sub.SubCode.ToString() + ")",
                    Value = sub.SubCode.ToString()

                };
                lk.Add(su);
            }
            lk = lk.GroupBy(x => x.Text).Select(x => x.First()).ToList();

            //Selection of Teacher

            return Json(lk, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetSubjectDep(int sem)
        {
            List<SelectListItem> Dl = new List<SelectListItem>();

            //Select Department list on basis of the Sem
            foreach (Subject sub in db.Subjects.Where(x => x.Sem == sem).ToList())
            {
                SelectListItem su = new SelectListItem
                {
                    Text = sub.DeptId.ToString().Trim(),
                    Value = sub.DeptId.ToString().Trim()
                };
                Dl.Add(su);
            }
            Dl = Dl.GroupBy(x => x.Text).Select(x => x.First()).ToList();
            return Json(Dl, JsonRequestBehavior.AllowGet);
        }
        public List<SelectListItem> Semmanu(string name)
        {


            List<SelectListItem> Semester = new List<SelectListItem>();
            List<spGetSem_Result> l = db.spGetSem(name).ToList();
            foreach (var s in l)
            {
                Semester.Add(new SelectListItem { Text = s.ID.ToString(), Value = s.Value.ToString() });
            }
            return Semester;

        }

        [HttpGet]
        public ActionResult Edit(int edit)
        {
            var a = (IndexVM)TempData["list"];
            var edit1 = a.ListofIndex[edit];
            foreach (var i in a.ListofIndex)
            {
                edit1.ListofIndex.Add(i);
            }
            edit1.ListofIndex.RemoveAt(edit);
            edit1.SubjectDeptList = a.SubjectDeptList;
            edit1.TeacherDetail = a.TeacherDetail;
            edit1.DepartmentList = a.DepartmentList;
            edit1.SectionList = a.SectionList;
            edit1.sec = a.sec;
            edit1.TeacherList = new SelectList(db.Teachers.Where(x => x.DeptId == edit1.Tdept), "TID", "TeacherName").ToList();
            edit1.TeacherList.Where(x => x.Value == edit1.TID).Select(t => t.Selected = true);
            edit1.Semester = Semmanu(edit1.Deptlist);
            edit1.SubjectList = new SelectList(db.Subjects.Where(x => x.Sem == edit1.Sem && x.DeptId == edit1.SDept), "SubCode", "SubName").ToList();
            TempData["list"] = edit1;
            return View("Index", edit1);
        }
        [HttpGet]
        public ActionResult Delete(int del)
        {
            var a = (IndexVM)TempData["list"];

            a.ListofIndex.RemoveAt(del);
            TempData["list"] = a;
            if (a.ListofIndex.Count == 0)
            {
                a.Deptlist = "0";
                a.Sem = 0;
                a.sec = "0";
                a.SDept = "0";
                a.Tdept = "0";
                a.TID = "0";
                a.subcode = "0";

            }
            TempData["list"] = a;

            return View("Index", a);
        }

        public String Generate_SubcombId(int Sem)
        {
            int count = 0;
            try
            {
                count = db.SubCombs.Max(c => c.Count) + 1;
            }
            catch (Exception)
            {
                if (count == 0)
                    count = 1;

            }
            if (count != 1) { count += 1; }
            char even;
            string t = "";
            if (Sem % 2 == 0)
                even = 'E';
            else
                even = 'O';
            if (count < 10)
                t = "00";
            else
                if (count < 100)
                    t = "0";


            string SubCombId = even + "2016" + t + (count.ToString());
            return SubCombId;
        }
        public JsonResult GetSection(string Deptid, int Sem)
        {
            List<SelectListItem> Section = new List<SelectListItem>();
            List<spGetSection_Result> l = db.spGetSection(Deptid.Trim(), Sem).ToList();
            foreach (var s in l)
            {
                Section.Add(new SelectListItem { Text = s.ID.ToString(), Value = s.Value.ToString().Trim() });
            }

            return Json(Section, JsonRequestBehavior.AllowGet);
        }


        public ActionResult ViewSubjectCombinations()
        {
            RNSITEntities db = new RNSITEntities();

            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var subCombs = db.SubCombs;
                return View(subCombs.ToList());
            }
            else
            {
                var subCombs = db.SubCombs.Where(x => x.DeptId == department);
                return View(subCombs.ToList());
            }
        }

        public ActionResult PrintSubjectCombinations()
        {
            RNSITEntities db = new RNSITEntities();

            string department = (string)TempData.Peek("Department");
            if (User.IsInRole("Admin"))
            {
                var subCombs = db.SubCombs;
                return View(subCombs.ToList());
            }
            else
            {
                var subCombs = db.SubCombs.Where(x => x.DeptId == department);
                return View(subCombs.ToList());
            }
        }

        public ActionResult AuthorizeSubComb()
        {
            return View();
        }

        public ActionResult Authorize()
        {
            string department = (string)TempData.Peek("Department");
            var students = db.SubCombs.Where(x => x.DeptId == department).ToList();
            for (int i = 0; i < students.Count; i++)
            {
                students[i].isValid = true;
                db.SubCombs.Attach(students[i]);
                db.Entry(students[i]).State = System.Data.Entity.EntityState.Modified;
                db.SaveChanges();
            }
            return View();
        }
    }
}