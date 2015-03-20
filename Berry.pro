icon_files.source = files/icons
icon_files.target = $${DESTDIR}/files
translation_files.source = files/translations
translation_files.target = $${DESTDIR}/files
DEPLOYMENTFOLDERS = translation_files icon_files

QT += widgets

unix:!macx {
    LIBS += -lexiv2
}
win32 {
#    LIBS += exiv/lib/libexiv2.dll
#    INCLUDEPATH += exiv/include
    QT += winextras
    RC_FILE = files/papyrus.rc
}

SOURCES += main.cpp \
    berry.cpp \
    iconprovider.cpp \
    thumbnailloaderitem.cpp \
    thumbnailloader.cpp \
    imagemetadata.cpp \
    pluginmanager.cpp \
    structures.cpp \
    pathhandler.cpp \
    pathhandlerimageprovider.cpp \
    SimpleQtCryptor/simpleqtcryptor.cpp \
    fileencrypter.cpp \
    passwordmanager.cpp \
    encrypttools.cpp

include(asemantools/asemantools.pri)
include(qmake/qtcAddDeployment.pri)
qtcAddDeployment()

HEADERS += \
    berry.h \
    iconprovider.h \
    berry_macros.h \
    thumbnailloaderitem.h \
    thumbnailloader.h \
    imagemetadata.h \
    pluginmanager.h \
    structures.h \
    pathhandler.h \
    pathhandlerimageprovider.h \
    SimpleQtCryptor/serpent_sbox.h \
    SimpleQtCryptor/simpleqtcryptor.h \
    fileencrypter.h \
    passwordmanager.h \
    encrypttools.h

TRANSLATIONS += \
    files/translations/lang-cs.qm \
    files/translations/lang-en.qm \
    files/translations/lang-fa.qm \
    files/translations/lang-ru.qm

isEmpty(PREFIX) {
    PREFIX = /usr
}

contains(BUILD_MODE,opt) {
    BIN_PATH = $$PREFIX/
    SHARES_PATH = $$PREFIX/
    APPDESK_PATH = /usr/
    APPDESK_SRC = files/shortcuts/opt/
} else {
    BIN_PATH = $$PREFIX/bin
    SHARES_PATH = $$PREFIX/share/berry/
    APPDESK_PATH = $$PREFIX/
    APPDESK_SRC = files/shortcuts/normal/
}

android {
} else {
linux {
    target = $$TARGET
    target.path = $$BIN_PATH
    translations.files = $$TRANSLATIONS
    translations.path = $$SHARES_PATH/files/translations
    icons.files = files/icons/berry.png
    icons.path = $$SHARES_PATH/icons/
    desktopFile.files = $$APPDESK_SRC/berry.desktop
    desktopFile.path = $$APPDESK_PATH/share/applications

    INSTALLS = target translations icons desktopFile
}
}

RESOURCES += \
    resource.qrc
