// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT

#pragma once

#include <unordered_map>
#include <string>

#include <QMainWindow>
#include <QAction>


class QLabel;
class QMenu;
class QPushButton;



class MyMainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MyMainWindow (QWidget *parent = nullptr);

private slots:

private:
    // Non-owning pointers to all the widgets we create. Qt is responsible
    // for deleting.
    QPushButton *button;
    QMenu *fileMenu, *editMenu, *viewMenu, *toolsMenu, *helpMenu;
    QLabel *statusLabel;

    // Add an action, with optional label (if different than the name),
    // hotkey shortcut and the method of lambda to call when the action is
    // triggered. The QAction* is returned, but you don't need to store it;
    // it will also be saved in the actions map, accessed by name. Note that
    // to do anything fancier, like have actions on hover, set tooltips, or
    // whatever, you'll need to do that using the QAction*.
    // http://doc.qt.io/qt-5/qaction.html
    template <typename ACT>
    QAction* add_action (const std::string &name, const std::string &label,
                         const std::string &hotkey="",
                         ACT trigger_action=nullptr) {
        QAction* act = new QAction (label.size() ? label.c_str() : name.c_str(), this);
        actions[name] = act;
        if (hotkey.size())
            act->setShortcut (QString(hotkey.c_str()));
        if (trigger_action)
            connect (act, &QAction::triggered, this, trigger_action);
        return act;
    }

    // Store all the actions in a list, accessed by name.
    std::unordered_map<std::string, QAction*> actions;

    // Create all the standard actions
    void createActions();

    // Create all the menu bar menus
    void createMenus();

    void createStatusBar ();

    // Actions. To make these do things, put them in the .cpp and give them
    // bodies. Delete the ones that don't correspond to concepts in your
    // app.
    void action_newfile () {}
    void action_open ();
    void action_close () {}
    void action_save () {}
    void action_saveas () {}
    void action_preferences () {}
    void action_copy () {}
    void action_cut () {}
    void action_paste () {}
    void action_hammer () {}
    void action_drill () {}
    void action_fullscreen () {}
    void action_about () {}
};

