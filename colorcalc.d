// Written in the D Programming Language, version 2

import std.stdio;
import std.string;
import std.conv;
import std.math;
import std.exception;

real gamma = 2.2;

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
			r = fromPixel(fromHex(s[0]) << 4 | fromHex(s[1]));
			g = fromPixel(fromHex(s[2]) << 4 | fromHex(s[3]));
			b = fromPixel(fromHex(s[4]) << 4 | fromHex(s[5]));
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
			int cval = toPixel(rval);
			return cval < 0 ? "--" : cval > 255 ? "**" : format("%02X", cval);
		}

		if (r==g && g==b)
			if (r<-0.0001 || r>1.0001)
				return to!string(r); // hack - we don't know if the user wants a scalar or a color
			else
				return cvalToStr(r) ~ cvalToStr(g) ~ cvalToStr(b) ~ " (" ~ to!string(r) ~ ")";
		return cvalToStr(r) ~ cvalToStr(g) ~ cvalToStr(b);
	}

	static private real fromPixel(int p)
	{
		real r = p / 255.0;
		if (gamma)
			r = pow(r, gamma);
		return r;
	}

	static private int toPixel(real v)
	{
		if (gamma)
			v = pow(v, 1/gamma);
		return cast(int)round(v * 255);
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

int main(string[] args)
{
	bool usage;
	for (int i=1; i<args.length; i++)
		switch (args[i])
		{
			case "-h":
			case "--help":
				usage = true;
				break;
			case "-g":
			case "--gamma":
				enforce(i+1<args.length, "Gamma value not specified");
				gamma = to!real(args[++i]);
				break;
			default:
				string expr = join(args[i..$], " ");
				writeln(eval(expr));
				return 0;
		}

	if (args.length == 1 || usage)
	{
		stderr.writeln("Usage: " ~ args[0] ~ " [--gamma GAMMA] EXPRESSION");
		stderr.writeln("Options:");
		stderr.writeln("  -h	--help		Display this help screen.");
		stderr.writeln("  -g	--gamma GAMMA	Use specified gamma value (default: 2.2).");
		stderr.writeln("			Specify 0 to disable gamma correction (mathematically equivalent to specifying 1).");
		return 2;
	}

	throw new Exception("No expression given.");
}
