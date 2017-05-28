using System;
using System.Collections.Generic;
using System.Drawing;

namespace AtlasPlistDestructor
{
    internal class Slice
    {
        public string name;
        public bool rotated;
        public Point sourceSize;
        public Rectangle rect;
        public Rectangle coloredRect;


        public Slice(string name, Dictionary<string, dynamic> dict) 
        {
            this.name = name;

            string frame = dict["frame"];
            frame = frame.Replace('{', ' ');
            frame = frame.Replace('}', ' ');
            string[] rr = frame.Split(',');

            rotated = dict["rotated"];
            rect = new Rectangle(int.Parse(rr[0]), int.Parse(rr[1]), int.Parse(rr[rotated ? 3 : 2]), int.Parse(rr[rotated ? 2 : 3]));

            string sourceColorRect = dict["sourceColorRect"];
            sourceColorRect = sourceColorRect.Replace('{', ' ');
            sourceColorRect = sourceColorRect.Replace('}', ' ');
            rr = sourceColorRect.Split(',');
            coloredRect = new Rectangle(int.Parse(rr[0]), int.Parse(rr[1]), int.Parse(rr[2]), int.Parse(rr[3]));

            string ss = dict["sourceSize"];
            ss = ss.Replace('{', ' ');
            ss = ss.Replace('}', ' ');
            rr = ss.Split(',');
            sourceSize = new Point(int.Parse(rr[0]), int.Parse(rr[1]));

            //Console.WriteLine(name + "  bounds:" + this.rect + "  rotated:" + rotated + "  coloredOffset:" + coloredOffset + "  sourceSize:" + sourceSize);
        }
    }
}