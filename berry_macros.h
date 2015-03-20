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

#ifndef BERRY_MACROS_H
#define BERRY_MACROS_H

#include <QDir>
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QFileInfo>

#ifdef Q_OS_WIN
#define HOME_PATH QString(QDir::homePath() + "/AppData/Local/aseman/berry")
#else
#define HOME_PATH QString(QDir::homePath() + "/.config/aseman/berry")
#endif

#define CONF_PATH QString(HOME_PATH + "/config.ini")
#define PLUGINS_LOCAL_PATH  QString(HOME_PATH + "/plugins")
#define PLUGINS_PUBLIC_PATH QString(QCoreApplication::applicationDirPath() + "/plugins")

#define NORMALIZE_PATH( PATH ) \
    while( PATH.left(7) == "file://" ) \
        PATH = PATH.mid(7); \
    PATH = QFileInfo(PATH).filePath();

#define PASS_FILE_NAME ".dont_remove_me.password"

#define PATH_HANDLER_NAME  "pathhandler"
#define PATH_HANDLER_LLOCK "berrylock"
#define PATH_HANDLER_LLOCK_THUMB "berrylock_thumb"
#define PATH_HANDLER_LLOCK_SUFFIX "limlock"
#define PATH_HANDLER_LLOCK_SUFFIX_THUMB "limlockthumb"

#define ENCRYPTER_HEADER  QString("Berry Encrypted File")
#define ENCRYPTER_VERSION 1.0

#define HASH_MD5( STRING ) QCryptographicHash::hash(STRING.toUtf8(),QCryptographicHash::Md5).toHex()

#endif // BERRY_MACROS_H
