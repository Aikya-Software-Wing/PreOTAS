using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PreOTAS.Models
{
    public class StudentError
    {
        public StudentError()
        {
            Errors = new List<Error>();
        }

        public string Usn { get; set; }
        public List<Error> Errors { get; set; }
    }
}