using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace PreOTAS.Models
{
    public class StudentMetaData
    {
        [Required]
        public string USN { get; set; }

        [Required]
        public string NAME { get; set; }

        [Required]
        [Range(1, 8)]
        public Nullable<int> Sem { get; set; }

        [Required]
        [MaxLength(1)]
        [MinLength(1)]
        public string Section { get; set; }
    }

    [MetadataType(typeof(StudentMetaData))]
    public partial class STUDENT
    {

    }
}