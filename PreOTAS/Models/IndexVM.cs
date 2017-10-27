using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PreOTAS.Models
{
    public class IndexVM
    {
        public IndexVM()
        {
            this.Semester = new List<SelectListItem>();
            this.TeacherList = new List<SelectListItem>();
            this.SubjectList = new List<SelectListItem>();
            this.SubjectDeptList = new List<SelectListItem>();
            this.DepartmentList = new List<SelectListItem>();
            this.SectionList = new List<SelectListItem>();
            this.ListofIndex = new List<IndexVM>();
        }
        public List<IndexVM> ListofIndex { get; set; }
        public List<SelectListItem> DepartmentList;
        public List<SelectListItem> Semester { get; set; }
        public List<SelectListItem> TeacherDetail { get; set; }
        public List<SelectListItem> SubjectList { get; set; }
        public List<SelectListItem> TeacherList { get; set; }
        public List<SelectListItem> SubjectDeptList { get; set; }
        public List<SelectListItem> SectionList { get; set; }

        public String SubjectName { get; set; }
        public String TeacherName { get; set; }
        public String SubCombId { get; set; }
        [Required]
        public String Deptlist { get; set; }
        [Required]
        [Range(1, 8)]
        public int Sem { get; set; }
        public String Tdept { get; set; }
        public String SDept { get; set; }

        [StringLength(255, MinimumLength = 2)]
        [Required]
        public String TID { get; set; }
        [StringLength(255, MinimumLength = 2)]
        [Required]
        public String subcode { get; set; }
        [Required]
        public string sec { get; set; }
        public int elective { get; set; }
        public int count { get; set; }
    }
}