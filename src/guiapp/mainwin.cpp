// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT


#include <iostream>

#include <QApplication>
#include <QDir>
#include <QFileDialog>
#include <QLabel>
#include <QMenu>
#include <QMenuBar>
#include <QPushButton>
#include <QStatusBar>

#include "mainwin.h"


MyMainWindow::MyMainWindow(QWidget* parent)
    : QMainWindow(parent)
{
    // read_settings ();

    setWindowTitle(tr("GUI App"));

    // Set size of the window
    // setFixedSize(100, 50);

    createActions();
    createMenus();

    // Create and position a button
    button = new QPushButton("Hello World", this);
    button->setGeometry(10, 10, 80, 30);
    setCentralWidget(button);

    connect(button, &QPushButton::clicked, QApplication::instance(),
            &QApplication::quit);

    // Status bar
    statusBar()->showMessage(tr("Status Bar"));
}



void
MyMainWindow::createActions()
{
    add_action("Exit", "E&xit", "Ctrl+Q", &QMainWindow::close);
    add_action("New file", "", "Ctrl+N", &MyMainWindow::action_newfile);
    add_action("Open...", "", "Ctrl+O", &MyMainWindow::action_open);
    add_action("Save", "", "Ctrl+S", &MyMainWindow::action_save);
    add_action("Save As...", "", "Shift-Ctrl+S", &MyMainWindow::action_saveas);
    add_action("Close File", "", "Ctrl+W", &MyMainWindow::action_close);
    add_action("Edit Preferences...", "", "",
               &MyMainWindow::action_preferences);
    add_action("About...", "", "", &MyMainWindow::action_about);

    add_action("Copy", "", "Ctrl+C", &MyMainWindow::action_copy);
    add_action("Cut", "", "Ctrl+X", &MyMainWindow::action_cut);
    add_action("Paste", "", "Ctrl+V", &MyMainWindow::action_paste);

    add_action("Hammer", "", "", &MyMainWindow::action_hammer);
    add_action("Drill", "", "", &MyMainWindow::action_drill);
    add_action("Enter Full Screen", "", "", &MyMainWindow::action_fullscreen);
}



void
MyMainWindow::createMenus()
{
    // openRecentMenu = new QMenu(tr("Open recent..."), this);
    // for (auto& i : openRecentAct)
    //     openRecentMenu->addAction (i);

    fileMenu = new QMenu(tr("&File"), this);
    fileMenu->addAction(actions["New file"]);
    fileMenu->addAction(actions["Open..."]);
    // fileMenu->addMenu (openRecentMenu);
    fileMenu->addAction(actions["Save"]);
    fileMenu->addAction(actions["Save As..."]);
    fileMenu->addAction(actions["Close File"]);
    fileMenu->addSeparator();
    fileMenu->addAction(actions["Exit"]);
    fileMenu->addSeparator();
    fileMenu->addAction(actions["Edit Preferences..."]);
    menuBar()->addMenu(fileMenu);

    editMenu = new QMenu(tr("&Edit"), this);
    editMenu->addAction(actions["Copy"]);
    editMenu->addAction(actions["Cut"]);
    editMenu->addAction(actions["Paste"]);
    menuBar()->addMenu(editMenu);

    viewMenu = new QMenu(tr("&View"), this);
    viewMenu->addAction(actions["Enter Full Screen"]);
    menuBar()->addMenu(viewMenu);

    toolsMenu = new QMenu(tr("&Tools"), this);
    toolsMenu->addAction(actions["Hammer"]);
    toolsMenu->addAction(actions["Drill"]);
    menuBar()->addMenu(toolsMenu);

    helpMenu = new QMenu(tr("&Help"), this);
    helpMenu->addAction(actions["About..."]);
    menuBar()->addMenu(helpMenu);
    // Bring up user's guide

    menuBar()->show();
}


void
MyMainWindow::createStatusBar()
{
    statusLabel = new QLabel;
    statusBar()->addWidget(statusLabel);
    statusLabel->setText("status message");
}



void
MyMainWindow::action_open()
{
    static const char* s_file_filters = "Images (*.tif,*.jpg,*.exr);;"
                                        "All Files (*)";

    QStringList files = QFileDialog::getOpenFileNames(
        nullptr, "Select one or more files to open", QDir::currentPath(),
        s_file_filters, nullptr, QFileDialog::Option::DontUseNativeDialog);

    for (auto& name : files) {
        std::string filename = name.toUtf8().data();
        if (filename.empty())
            continue;
        std::cout << filename << "\n";
    }
}
