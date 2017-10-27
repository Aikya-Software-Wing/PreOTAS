using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PreOTAS.Models
{
    public class ElectiveError
    {
        public ElectiveError()
        {
            Errors = new List<Error>();
        }

        public string Usn { get; set; }
        public string SubjectCode { get; set; }
        public List<Error> Errors { get; set; }
    }
}