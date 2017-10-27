using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace PreOTAS.Models
{
    public class SubjectMetadata
    {
        [Required]
        public string SubCode { get; set; }

        [Required]
        public string SubName { get; set; }

        [Required]
        [Range(1, 8)]
        public int Sem { get; set; }

        [Required]
        public Nullable<int> Elective { get; set; }
    }

    [MetadataType(typeof(SubjectMetadata))]
    public partial class Subject
    {

    }
}