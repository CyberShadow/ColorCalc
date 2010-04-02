import std.stdio;
import std.string;
import std.conv;
import std.math;

struct Color
{
	int r,g,b;

	this(int r, int g, int b) { this.r = r; this.g = g; this.b = b; }
	
	this(string s)
	{
		static int fromHex(char c)
		{
			int p = indexOf("0123456789ABCDEF", c, CaseSensitive.no);
			if (p < 0)
				throw new Exception("Bad hex digit " ~ c);
			return p;
		}
		
		if (s.length == 6)
		{
			r = fromHex(s[0]) << 4 | fromHex(s[1]);
			g = fromHex(s[2]) << 4 | fromHex(s[3]);
			b = fromHex(s[4]) << 4 | fromHex(s[5]);
		}
		else
			r = g = b = cast(int)round(to!real(s) * 255);
	}

	Color opBinary(string op)(Color o)
	{
		static if (op == "+" || op == "-")
			mixin("return Color(r"~op~"o.r, g"~op~"o.g, b"~op~"o.b);");
		else
		static if (op == "*")
			return Color(r*o.r / 255, g*o.g / 255, b*o.b / 255);
		else
		static if (op == "/")
			return Color(r*255 / o.r, g*255 / o.g, b*255 / o.b);
		else
			static assert(0, "Don't know how to " ~ op ~ " two Colors");
	}

	string toString()
	{
		static string cvalToStr(int cval)
		{
			return cval < 0 ? "--" : cval > 255 ? "**" : format("%02X", cval);
		}

		return cvalToStr(r) ~ cvalToStr(g) ~ cvalToStr(b);
	}
}

Color eval(string expr)
{
	expr = strip(expr);
	int p1, p2;
	if ((p1=indexOf(expr, '('))>=0)
	{
		p2 = lastIndexOf(expr, ')');
		if (p2 < 0)
			throw new Exception("Unmatched parenthesis");
		return eval(expr[0..p1] ~ eval(expr[p1+1..p2]).toString() ~ expr[p2+1..$]);
	}

	static int firstOf(int a, int b)
	{
		return a < 0 ? b : b < 0 ? a : a < b ? a : b;
	}

	p1 = firstOf(indexOf(expr, '+'), indexOf(expr, '-'));
	p2 = firstOf(indexOf(expr, '*'), indexOf(expr, '/'));
	if (p1 >= 0)
		if (expr[p1]=='+')
			return eval(expr[0..p1]) + eval(expr[p1+1..$]);
		else
			return eval(expr[0..p1]) - eval(expr[p1+1..$]);
	if (p2 >= 0)
		if (expr[p2]=='*')
			return eval(expr[0..p2]) * eval(expr[p2+1..$]);
		else
			return eval(expr[0..p2]) / eval(expr[p2+1..$]);
	return Color(expr);
}

void main(string[] args)
{
	if (args.length == 1)
		return writefln("Please enter an expression.");
	string expr = join(args[1..$], " ");
	writefln("%s", eval(expr));
}
