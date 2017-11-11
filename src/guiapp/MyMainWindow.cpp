// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT


#include <QApplication>

#include "MyMainWindow.h"


MyWindow::MyWindow (QWidget *parent)
    : QMainWindow(parent)
{
    // read_settings ();

    setWindowTitle (tr("GUI App"));

    // Set size of the window
    // setFixedSize(100, 50);

    // Create and position a button
    m_button = new QPushButton("Hello World", this);
    m_button->setGeometry (10, 10, 80, 30);
    setCentralWidget (m_button);

    connect (m_button, SIGNAL (clicked()), QApplication::instance(), SLOT (quit()));
}
