REQUIREMENTS
	Max 5
	
DIRECTORIES
	ObjectiveMax:
		MaxObject			--	The source code for the MaxObject framework
		MaxObject.framework	--	An already compiled MaxObject framework for the Mac
		MaxObject-Examples 	--	Example Max externals written in Objective-C
	TTBlue	 				--	Files for the core classes from TTBlue.  
								These are used to build the MaxObject Framework, should you choose to build it yourself

HOW TO BUILD OBJECTS -- MAC

	1. Copy the MaxObject.framework to /Library/Frameworks (or build it)
	2. Open the Xcode project
	3. Click the hammer icon or choose 'Build' from the menus
	4. The external will need to be copied/added into the Max searchpath


HOW TO BUILD OBJECTS -- WINDOWS

If you have the development environment set up on Windows (see below) then you can simply follow these steps:

	1.	Start the MSYS/MinGW terminal
	2.	'cd' to the project directory
	3.	run './build.sh'
	4.	The external will need to be copied/added into the Max searchpath
	5.	The dll files in the 'win-support' folder need to be copied into the Max folder.
	
Note that on Windows there is no shared library for the MaxObject framework like there is on the Mac.  There are makefiles and scripts for building such a DLL, but linking against it is very problematic.  Therefore, the recommended way to compile externals on Windows is to compile the MaxObject framework directly into the object.

Setting up the development environment on Windows takes a little bit of work.  In order to use Objective-C you really need to have the foundation classes.  This is standard on the Mac, but on Windows it requires the use of the open-source GNUstep.  

The instructions for installing GNUstep is an okay place to start.  They are located here:
	http://gnustep.org/resources/documentation/User/GNUstep/README.MinGW
	
However, at the time of this writing, they are lacking in a few details.  Below is an addendum to the GNUstep install directions with some comments and notes.

	0.0 Don't even consider trying to use gcc on Cygwin for compiling with GNUstep, it won't work.  You need to MinGW.
	0.1 Don't use the GNUstep installer.  It sucks.  Many hours were wasted by trying to use the stuff it installed.
	
	3.0 The msysDTK is actually hard to find.  It says to find it from the same site, which is sorta wrong.
		If it just means 'from sourceforge' which is sorta the same then it's right.  Anyway, just Google for
		'msysDTK-1.0.1' and you will save your self a lot of time.
	3.1 Maybe due to lack of expertise at predicting what happens when things are installed on Windows, it seems
		like it is easy to install this to the wrong place.  Fortunately, if it does get installed to the wrong folder
		(e.g. you look in the 1.0 folder and see another 1.0 folder) you can just move the files and it seems to
		be okay.
	
	5.0 As it says, this is optional
	
	8.0 Skip this one
	
	11.0 It's more of a repeated crash notification than a simple failure.  Whatever.

	12.0 Once again, these aren't all at the same site.  You are best off just doing a Google on the 
		filenames to locate the downloads.
		
	14.0 This is the last required step for the MaxObject support.  
	
	15.0 You would think that these steps would now be optional, and not required for non-ui objects.
		However, you would be wrong.  Continue following the installation instructions...

Once you have GNUstep involved, you will also need to make sure that gcc is able to find the Max SDK.  The Makefile here assumes that the SDK is located at:
	/maxmspsdk
You can either copy the SDK here or make a symbolic link.  However, keep the following step(s) in mind.

	1. In ext_mess.h, you need to change a struct definition to avoid conflicts with the objc runtime.  Specifically,
		you need to find this:
			} t_object, Object;
		and change it to this:
			} t_object;
		So that both are not defining Object.

	2. In ext_prefix.h, you need to make a modification for what seems like a bug in GCC:
		you need to find this:
			#ifndef WIN_VERSION
			#define MAC_VERSION 1
			#endif
		and replace it with this:
			#define WIN_VERSION 1

	3. If you wish to avoid pragma warnings (optional), then delete the lines that begin with this:
			#pragma warning

Similarly, the makefile here also assumes that you have a copy of TTBlue 0.4.x ( http://electrotap.com/ttblue ) on your system, and that the TTBlue folder is located relative to the MaxObject framework source folder at 
	../../TTBlue
Again, you can either copy the files here or make a symbolic link.  The directory structure as downloaded in this archive should be correct already.


Finally, you need to either install the MaxObject library files, or build them from source.  You should do this even though you won't be linking against it, because it will place the header files in a location easily defined and found by the compiler.
	1. Run ./build.sh from command prompt
