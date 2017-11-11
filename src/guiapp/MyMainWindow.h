// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT


#include <QMainWindow>
#include <QWidget>
#include <QPushButton>


class MyWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MyWindow (QWidget *parent = nullptr);
private slots:
private:
    QPushButton* m_button;
};

