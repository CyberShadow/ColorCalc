import std.stdio;
import std.string;
import std.conv;
import std.math;

struct Color
{
	real r,g,b;

	this(real r, real g, real b) { this.r = r; this.g = g; this.b = b; }
	
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
			r = (fromHex(s[0]) << 4 | fromHex(s[1])) / 255.0;
			g = (fromHex(s[2]) << 4 | fromHex(s[3])) / 255.0;
			b = (fromHex(s[4]) << 4 | fromHex(s[5])) / 255.0;
		}
		else
			r = g = b = to!real(s);
	}

	Color opBinary(string op)(Color o)
	{
		mixin("return Color(r"~op~"o.r, g"~op~"o.g, b"~op~"o.b);");
	}

	string toString()
	{
		static string cvalToStr(real rval)
		{
			int cval = cast(int)round(rval * 255);
			return cval < 0 ? "--" : cval > 255 ? "**" : format("%02X", cval);
		}

		if (r==g && g==b)
			if (r<-0.0001 || r>1.0001)
				return to!string(r);
			else
				return cvalToStr(r) ~ cvalToStr(g) ~ cvalToStr(b) ~ " (" ~ to!string(r) ~ ")";
		return cvalToStr(r) ~ cvalToStr(g) ~ cvalToStr(b);
	}
}

Color eval(string expr)
{
	expr = strip(expr);

	static int findOperand(string s, char op1, char op2)
	{
		int parens = 0;
		foreach_reverse(p, c; s)
			if ((c==op1 || c==op2) && parens==0)
				return p;
			else
			if (c==')')
				parens++;
			else
			if (c=='(')
				parens--;
		return -1;
	}
	
	int p1 = findOperand(expr, '+', '-');
	int p2 = findOperand(expr, '*', '/');
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
	if (expr.length > 2 && expr[0]=='(' && expr[$-1]==')')
		return eval(expr[1..$-1]);
	return Color(expr);
}

void main(string[] args)
{
	if (args.length == 1)
		return writefln("Please enter an expression.");
	string expr = join(args[1..$], " ");
	writefln("%s", eval(expr));
}
