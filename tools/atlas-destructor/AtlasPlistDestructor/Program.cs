using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

namespace AtlasPlistDestructor
{
    class Program
    {
        static void Main(string[] args)
        {

            /*DirectoryInfo d = new DirectoryInfo(@"C:\Users\ManJav\Desktop\New folder");
            FileInfo[] infos = d.GetFiles();
            foreach (FileInfo f in infos)
            {
                //var fn = f.FullName.ToString().Replace(" (", "-");
                //fn = fn.Replace(")", "");
                //  DwarfINF_Move_Down_001 copy
                var nl = f.Name;//.Split('_');
                //var nm = nl[3] + "-" + nl[4] + "-" + nl[5].Substring(0, 3) + ".png";

                Console.WriteLine("C:\\Users\\ManJav\\Desktop\\New folder\\" + nl.Replace("building", "building-ex"));
                 File.Move(f.FullName, "C:\\Users\\ManJav\\Desktop\\New folder\\" + nl.Replace("building", "building-ex"));
            }
            Console.Read();

            return;*/

            string atlasName = Console.ReadLine();
            var plist = new PList();
            plist.Load("C:\\Users\\ManJav\\Desktop\\" + atlasName + ".plist");

            List<Slice> slices = new List<Slice>();
            var frames = plist["frames"];
            foreach (var k in frames.Keys)
                slices.Add(new Slice(k, frames[k]));

            Bitmap image1 = (Bitmap)Image.FromFile(@"C:\\Users\\ManJav\\Desktop\\" + atlasName + ".png");
            Bitmap sub = null;
            Bitmap b;
            foreach (var s in slices)
            {
                sub = image1.Clone(s.rect, PixelFormat.Format32bppArgb);

                if(s.rotated)
                    sub.RotateFlip(RotateFlipType.Rotate270FlipNone);

                b = new Bitmap(s.sourceSize.X, s.sourceSize.Y);

                using (Graphics g = Graphics.FromImage(b))
                {
                    g.DrawImage(sub, s.coloredRect);
                }

                b.Save("C:\\Users\\ManJav\\Desktop\\"+atlasName+"\\" + s.name);
                Console.WriteLine("C:\\Users\\ManJav\\Desktop\\" + atlasName + "\\" + s.name);
                sub.Dispose();
                b.Dispose();
            }
            image1.Dispose();
            Console.Read();

        }
    }
}
