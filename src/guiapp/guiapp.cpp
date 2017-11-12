// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT

#include <iostream>

#include <QApplication>
#include <QWidget>
#include <QPushButton>

#include <OpenImageIO/argparse.h>
#include <OpenImageIO/filesystem.h>
#include <Proto/Proto.h>

#include "mainwin.h"


#ifdef WIN32
    // if we are not in DEBUG mode this code switch the app to
    // full windowed mode (no console and no need to define WinMain)
    // FIXME: this should be done in CMakeLists.txt but first we have to
    // fix Windows Debug build
# ifdef NDEBUG
#  pragma comment(linker, "/subsystem:windows /entry:mainCRTStartup")
# endif
#endif


static bool verbose = false;
// static bool foreground_mode = false;
static std::vector<std::string> filenames;


static int
parse_files (int argc, const char *argv[])
{
    for (int i = 0;  i < argc;  i++)
        filenames.emplace_back(argv[i]);
    return 0;
}


static void
getargs (int argc, char *argv[])
{
    bool help = false;
    OIIO::ArgParse ap;
    ap.options ("guiapp -- example GUI app\n"
                Proto_INTRO_STRING "\n"
                "Usage:  guiapp [options] [filename...]",
                  "%*", parse_files, "",
                  "--help", &help, "Print help message",
                  "-v", &verbose, "Verbose status messages",
                  // "-F", &foreground_mode, "Foreground mode",
                  NULL);
    if (ap.parse (argc, (const char**)argv) < 0) {
        std::cerr << ap.geterror() << std::endl;
        ap.usage ();
        exit (EXIT_FAILURE);
    }
    if (help) {
        ap.usage ();
        exit (EXIT_FAILURE);
    }
}




int
main (int argc, char* argv[])
{
    OIIO::Filesystem::convert_native_arguments (argc, (const char **)argv);

    std::cout << Proto_INTRO_STRING << "\n";
    std::cout << Proto_COPYRIGHT_STRING << "\n";
    Proto::hello();

    getargs (argc, argv);

    // if (! foreground_mode)
    //     Sysutil::put_in_background (argc, argv);

    QApplication app(argc, argv);
    MyMainWindow win;
    win.show();

    int qtresult = app.exec();

    // Clean up here

    return qtresult;
}
