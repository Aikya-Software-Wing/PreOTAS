using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.Owin;
using Owin;
using PreOTAS.Models;
using System.Collections.Generic;
using System.Web.Security;
using System.Linq;

[assembly: OwinStartupAttribute(typeof(PreOTAS.Startup))]
namespace PreOTAS
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
            CreateRolesAndUsers();
        }

        public void CreateRolesAndUsers()
        {
            ApplicationDbContext context = new ApplicationDbContext();

            var roleManager = new RoleManager<IdentityRole>(new RoleStore<IdentityRole>(context));
            var UserManager = new UserManager<ApplicationUser>(new UserStore<ApplicationUser>(context));

            if (!roleManager.RoleExists("Clerk"))
            {
                var role = new IdentityRole();
                role.Name = "Clerk";
                roleManager.Create(role);
            }


            if (!roleManager.RoleExists("Hod"))
            {
                var role = new IdentityRole();
                role.Name = "Hod";
                roleManager.Create(role);
            }

            if (!roleManager.RoleExists("Admin"))
            {
                var role = new IdentityRole();
                role.Name = "Admin";
                roleManager.Create(role);
            }

            RNSITEntities db = new RNSITEntities();
            List<DEPT> departmentList = db.DEPTs.ToList();

            foreach (var department in departmentList)
            {
                var userName = department.DeptId.ToLower().Trim() + "@rnsit.ac.in";
                if (UserManager.FindByEmail(userName) == null)
                {
                    var user = new ApplicationUser();
                    user.UserName = userName;
                    user.Email = userName;
                    string userPWD = "P@ssw0rd@" + department.DeptId.ToLower().Trim();

                    var chkUser = UserManager.Create(user, userPWD);
                    if (chkUser.Succeeded)
                    {
                        UserManager.AddToRole(user.Id, "Clerk");
                    }

                    department.Password = userPWD;

                    userName = department.DeptId.ToLower().Trim() + "@hod.rnsit.ac.in";
                    user = new ApplicationUser();
                    user.UserName = userName;
                    user.Email = userName;
                    userPWD = "P@ssw0rd@" + department.DeptId.ToLower().Trim();

                    chkUser = UserManager.Create(user, userPWD);
                    if (chkUser.Succeeded)
                    {
                        UserManager.AddToRole(user.Id, "Hod");
                    }

                    department.HodPassword = userPWD;
                    db.DEPTs.Attach(department);
                    db.Entry(department).State = System.Data.Entity.EntityState.Modified;
                    db.SaveChanges();
                }
            }
        }
    }
}
