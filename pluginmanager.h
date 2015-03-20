/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Berry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Berry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef PLUGINMANAGER_H
#define PLUGINMANAGER_H

#include <QObject>

class PluginManagerPrivate;
class PluginManager : public QObject
{
    Q_OBJECT
public:
    PluginManager(QObject *parent = 0);
    ~PluginManager();

private slots:
    void watcher_dir_changed( const QString & file );

private:
    void init_list();

private:
    PluginManagerPrivate *p;
};

#endif // PLUGINMANAGER_H
