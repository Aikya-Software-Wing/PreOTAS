using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace PreOTAS.Models
{
    public class TeacherMetaData
    {
        [Required]
        public string TeacherName { get; set; }

        [Required]
        public string Designation { get; set; }

        [Required]
        [EmailAddress]
        [DataType(DataType.EmailAddress)]
        public string E_mail { get; set; }
    }

    [MetadataType(typeof(TeacherMetaData))]
    public partial class Teacher
    {

    }
}