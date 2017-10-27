using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace PreOTAS.Models
{
    public class StudentTeacherRetrival
    {
        [MaxLength(10), MinLength(10)]
        [Required(ErrorMessage = "USN is required to proceed")]
        [DisplayName("USN")]
        public string USN { get; set; }
        [DisplayName("Subject Code")]
        public string subcode { get; set; }

        [DisplayName("Subject Name")]
        public string subName { get; set; }

        [DisplayName("Teacher Name")]
        public string Teacher { get; set; }

        [DisplayName("Elective")]
        public bool Elective { get; set; }
    }
}