<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="vargs.css" type="text/css">
<title>GiNaC ${ginacVersion} for Windows (MinGW)</title>
<%
def f_tarballUrl(ginacVersion, clnVersion, gmpVersion):
    fmt = './ginac-%s-cln-%s-gmp-%s-i686-w64-mingw32.tar.bz2'
    return fmt % ( ginacVersion, clnVersion, gmpVersion )

tarballUrl = f_tarballUrl(ginacVersion, clnVersion, gmpVersion)
tarball = '<a href="%s">tarball</a>' % tarballUrl

GiNaC = '<a href="http://www.ginac.de">GiNaC</a>'
CLN = '<a href="http://www.ginac.de/CLN">CLN</a>'
CLN_MailList = '<a href="https://www.ginac.de/mailman/listinfo/cln-list">CLN mailing list</a>'
GMP = '<a href="http://gmplib.org">GMP</a>'
TDM_GCC = '<a href="http://tdm-gcc.tdragon.net">TDM-GCC</a>'
TDM_GCC_Installer = '<a href="http://sourceforge.net/projects/tdm-gcc/files/TDM-GCC%20Installer/tdm64-gcc-4.5.2.exe">installer</a>'
MinGW_W64 = '<a href="http://mingw-w64.sourceforge.net">MinGW-w64</a>'
MinGW = '<a href="http://www.mingw.org">MinGW</a>'
Cygwin = '<a href="http://www.cygwin.com">Cygwin</a>'
msys = '<a href="http://www.mingw.org/msys.shtml">msys</a>'
ginacPrefix = '/opt/i686-w64-mingw32/ginac'
ginacPrefixWoe32 = 'C:\\GiNaC\\opt\\i686-w64-mingw32\\ginac'


myEmail = '&#65;&#108;&#101;&#120;&#101;&#105;&#46;&#83;&#104;&#101;&#112;&#108;&#121;&#97;&#107;&#111;&#118;&#64;&#103;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;'

def BigWarning(msg):
    return '<b style="color: red">%s</b>' % msg

%>
</head>
<body>

<div id="main">
<h1 class="pagetitle">${GiNaC} for Windows</h1>
<hr>
<p>
Here is ${MinGW} build of ${GiNaC} version ${ginacVersion}, and required
libraries: ${CLN} version ${clnVersion}, and ${GMP} version ${gmpVersion}.
The ${tarball} (${'<a href="%s.md5">MD5 sum</a>' % tarballUrl})
contains the headers, DLLs, import libraries, documentation (in PDF format),
and utilities (<tt>ginsh</tt>, <tt>viewgar</tt>, and <tt>pi</tt>).
</p>
<h2 style="color: red"><b>Note: these packages can be used only with GNU
toolchain (compiler, assembler, linker).</b></h2>
<h2>Supported compilers</h2>
<p>
GCC version &#gt;= 4.4 should work (both ${MinGW} and ${MinGW_W64} flavours).
</p>

<a name="install"></a>
<h2>Installation</h2>
<p>
First of all, install the GNU compiler itself. The easiest ways is to use
the ${TDM_GCC} ${TDM_GCC_Installer}.
</p>
<p>
Next, unpack the ${tarball} somewhere, say <tt>C:\GiNaC</tt>, and add
the <tt>${ginacPrefixWoe32}\bin</tt> directory to the <tt>PATH</tt>
environment variable.
</p>

<h2>Compiling and running a simple program.</h2>
<p>
Suppose we want to compile a simple program <tt>mycode.cpp</tt> which uses
${GiNaC}. This can be done in a several ways.
</p>

<h3>Using the command prompt (<tt>cmd.exe</tt>)</h3>
<p>
Start the shell (<tt>Start</tt> -&#gt; <tt>Run</tt> cmd.exe), and and compile
the program:
</p>
<p class="code">
set CPPFLAGS=-I"${ginacPrefixWoe32}\include" <br>
set LDFLAGS=-L"${ginacPrefixWoe32}\lib"
g++ -o mycode.exe %CPPFLAGS% %LDFLAGS% mycode.cpp -lginac -lcln -lgmp
</p>
Make sure <tt>${ginacPrefixWoe32}\bin</tt> is in the <tt>PATH</tt>, and run
the program:
<p class="code">
.\mycode.exe
</p>

<h3>Using the ${msys} environment.</h3>
<p>
Start the ${msys} shell, and run the following commands:
</p>
<p class="code">
export CPPFLAGS="-I${ginacPrefix}/include" <br>
export LDFLAGS="-L${ginacPrefix}/lib" <br>
g++ -o mycode.exe $CPPFLAGS $LDFLAGS mycode.cpp -lginac -lcln -lgmp
</p>

<a name="usingWithIDEs"></a>
<h3>Other ways.</h3>
<p>
It is possible to use these libraries with IDEs supporting
<a href="http://gcc.gnu.org">the GNU Compiler Collection</a>, such as
<a href="http://qt.nokia.com/products/developer-tools">Qt Creator</a>,
<a href="http://www.codeblocks.org">Code::Blocks</a>, etc.
</p>

<hr>

<h2>Reporting problems</h2>
<p>
Send bug reports, success stories, feature requests, etc. to
${myEmail}
</p>

<h2>Known issues</h2>
<ul style="list-style-type:square;">
	<li>
	<tt>tests/misc/t-scanf</tt> from the ${GMP} test suite fails.
	This looks like a MinGW runtime bug. It doesn't seem to affect
	the results of calculations, though.
	</li>
	<li>
	Only shared libraries are provided, since the shared and static versions
	of the ${GMP} library are binary incompatible.
	</li>
	<li>
	<tt>test_I_io</tt> check from the ${CLN} test suite fails. This does
	not affect results of calculations.
	</li>
</ul>

<hr>

<h2>FAQ</h2>

<p><b>Q:</b>
How do I use these libraries with Visual C++?<br>
<b>A:</b>
You don't. <b>These packages can be used only with GNU C++ compiler.</b>
In general, it's impossible to link <b>C++</b> libraries compiled by
different compilers (see e.g.
<a href="http://parashift.com/c++-faq-lite/compiler-dependencies.html#faq-38.9"
	>this explanation</a>).
</p>

<p><b>Q:</b>
How do I compile ${GiNaC} with Visual C++?<br>
<b>A:</b> 
I can't give a definitive answer, since I don't use that compiler myself.
Anyway, there's (at least) two things you should do. First of all,
the ${CLN} library contains a bit of GCC
specific code. You need to identify compiler specific code, and rewrite
it in a (reasonably) portable manner. You might want to send patches to
the ${CLN_MailList}, so you don't need to do this boring work whenever
a new version of ${CLN} is released.
The suggestions below can greatly increase the chances of your changes
being accepted:
<ul style="list-style-type: square; display: inline-block;">
    <li> Describe your changes: explain what problem you are trying solve,
         what are you doing to solve it, and why are you taking a particular
	 approach. </li>
    <li> Separate <i>logical changes</i> into a single patch file.
         For example, if you changes include both compilation fix and
	 performance enhancements, separate those changes into two or
	 more patches. On the other hand, if you make a single change
	 to numerous files (for example, API update), group those changes
	 into a single patch.
    <li> Mind the performance, please. </li>
    <li> Don't introduce regressions (in particular, build failures) for
         the primary platform (i.e. GNU/Linux). </li>
    <li> Don't add even more compiler- or OS-specific code unless
         it's absolutely necessary. </li>
    <li> Don't mix platform specific code with the generic one (put platform
         specific code into a different function, macros, file, etc). </li>
    <li> Don't <b>replace</b>
	 the <a href="http://en.wikipedia.org/wiki/GNU_build_system"
	 >auto tools</a> based build system with something else.
         That said, adding support for other build system(s) is welcome. </li>
</ul>
Secondly, you need to write build scripts for Visual C++ (or "project files",
or whatever m$ calls them) for ${GiNaC} and ${CLN}. 
<p>
Last, but not least: <b>don't ask developers to do this work for you unless
you are willing to pay for it</b>.
</p>

</div>
</body>
</html>

<!-- 
vim: ft=html
-->
