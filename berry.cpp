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

#include "berry.h"
#include "berry_macros.h"
#include "imagemetadata.h"
#include "iconprovider.h"
#include "pathhandler.h"
#include "pathhandlerimageprovider.h"
#include "thumbnailloader.h"
#include "fileencrypter.h"
#include "passwordmanager.h"
#include "asemantools/asemandesktoptools.h"
#include "asemantools/asemanquickview.h"

#include <QQmlEngine>
#include <QQmlContext>
#include <QtQml>
#include <QGuiApplication>
#include <QDir>
#include <QFileInfo>
#include <QDesktopServices>
#include <QStringList>
#include <QDebug>
#include <QImageReader>
#include <QDir>
#include <QSettings>
#include <QClipboard>
#include <QMimeData>
#include <QProcess>
#include <QPalette>
#include <QScreen>
#include <QStringList>
#include <QMimeDatabase>
#include <QDesktopWidget>
#include <QApplication>

#ifdef Q_OS_MAC
#include <QMainWindow>
#include <QToolBar>
#include <QHBoxLayout>
#endif

#ifdef Q_OS_WIN
#include <QtWinExtras/QtWin>
#endif

class BerryPrivate
{
public:
    AsemanQuickView *viewer;
    IconProvider *icon_provider;
    ThumbnailLoader *thumbnail_loader;
    PathHandlerImageProvider *handler_provider;
    FileEncrypter *encrypter;
    PasswordManager *pass_manager;

    bool fullscreen;
    bool highContrast;
    bool highGamma;
    bool highBright;
    bool initialized;
    bool fcrThumbnailBar;
    bool nrmlThumbnailBar;

    QString homePath;
    QString confPath;

    QSettings *settings;

    QTranslator *translator;
    QHash<QString,QVariant> languages;
    QHash<QString,QLocale> locales;
    QString currentLanguage;

    QMimeDatabase db;

#ifdef Q_OS_MAC
    QMainWindow *mwin;
#endif
};

Berry::Berry(QObject *parent) :
    QObject(parent)
{
    p = new BerryPrivate;
    p->viewer = 0;
    p->fullscreen = false;
    p->initialized = false;
    p->homePath = HOME_PATH;
    p->confPath = CONF_PATH;
    p->translator = new QTranslator(this);

    QIcon::setThemeName("FaenzaFlattr");
    QDir().mkpath(p->homePath);

    p->settings = new QSettings(p->confPath,QSettings::IniFormat,this);
    p->fcrThumbnailBar = p->settings->value("General/fcrThumbnailBar",false).toBool();
    p->nrmlThumbnailBar = p->settings->value("General/nrmlThumbnailBar",true).toBool();
    p->highContrast = p->settings->value("General/highContrast",true).toBool();
    p->highGamma = p->settings->value("General/highGamma",false).toBool();
    p->highBright = p->settings->value("General/highBright",false).toBool();

    qmlRegisterType<ImageMetaData>("land.aseman.berry", 1, 0, "ImageMetaData");
    qmlRegisterType<PathHandler>("land.aseman.berry", 1, 0, "PathHandler");

    init_languages();
}

QString Berry::home() const
{
    return QDir::homePath();
}

QString Berry::startDirectory() const
{
    const QStringList & args = QGuiApplication::arguments();
    if( args.count() <= 1 )
        return home();

    const QString & filePath = args.at(1);

    QFileInfo file(filePath);
    if( !file.exists() )
        return home();
    else
    if( file.isDir() )
        return filePath;
    else
        return file.dir().path();
}

QString Berry::inputPath() const
{
    const QStringList & args = QGuiApplication::arguments();
    if( args.count() <= 1 )
        return QString();

    const QString & filePath = args.at(1);
    QFileInfo file(filePath);
    if( !file.exists() )
        return QString();

    return filePath;
}

bool Berry::startViewMode() const
{
    const QString & path = inputPath();
    if( path.isEmpty() )
        return false;

    return QFileInfo(path).isFile();
}

bool Berry::initialized() const
{
    return p->initialized;
}

QString Berry::aboutAseman() const
{
    return tr("Aseman is a not-for-profit research and software development team launched in February 2014 focusing on development of products, technologies and solutions in order to publish them as open-source projects accessible to all people in the universe. Currently, we are focusing on design and development of software applications and tools which have direct connection with end users.") + "\n\n" +
            tr("By enabling innovative projects and distributing software to millions of users globally, the lab is working to accelerate the growth of high-impact open source software projects and promote an open source culture of accessibility and increased productivity around the world. The lab partners with industry leaders and policy makers to bring open source technologies to new sectors, including education, health and government.");
}

QString Berry::aboutBerry() const
{
    return tr("Berry is a modern image viewer ,focusing on user interface and user friendly.") + "\n"
            + tr("Berry is Free software and released under GPLv3 License.");
}

QString Berry::version() const
{
    return "1.1.0";
}

QSize Berry::imageSize(QString path) const
{
    NORMALIZE_PATH(path)
    if( path.isEmpty() )
        return QSize();

    QFileInfo inf(path);
    if( inf.suffix() == PATH_HANDLER_LLOCK_SUFFIX )
        return FileEncrypter::readSize(path);

    ImageMetaData mdata;
    mdata.setSource(path);

    QSize res = QImageReader(path).size();
    if( mdata.orientation() == ImageMetaData::Left || mdata.orientation() == ImageMetaData::Right )
        res = QSize(res.height(),res.width());

    return res;
}

quint64 Berry::fileSize(QString path) const
{
    NORMALIZE_PATH(path)
    return QFileInfo(path).size();
}

QString Berry::fileName(QString path) const
{
    NORMALIZE_PATH(path)
    return QFileInfo(path).fileName();
}

bool Berry::isSVG(QString path) const
{
    NORMALIZE_PATH(path)
    QString suffix = p->db.mimeTypeForFile(path).preferredSuffix();
    if( suffix == "svg" || suffix == "svgz" )
        return true;
    else
        return false;
}

QStringList Berry::folderEntry(QString path, const QStringList & filter, int count) const
{
    NORMALIZE_PATH(path)
    const QStringList & result = QDir(path).entryList(filter,QDir::Files,QDir::Name);
    if( count == -1 )
        return result;
    else
        return result.mid(0,count);
}

void Berry::deleteFiles(const QStringList &files)
{
    foreach( const QString & file, files )
        deleteFile(file);
}

bool Berry::deleteFile(QString file)
{
    NORMALIZE_PATH(file)
    return QFile(file).remove();
}

bool Berry::openDirectory(QString path)
{
    NORMALIZE_PATH(path)
    QString dir = path;

    QFileInfo inf(path);
    if( inf.isFile() )
        dir = inf.dir().path();

    return QDesktopServices::openUrl( QUrl::fromLocalFile(dir) );
}

QString Berry::directoryOf(QString path)
{
    NORMALIZE_PATH(path)
    return QFileInfo(path).dir().path();
}

bool Berry::isDirectory(QString path)
{
    NORMALIZE_PATH(path)
    return QFileInfo(path).isDir();
}

bool Berry::createDirectory(QString path)
{
    NORMALIZE_PATH(path)
    return QDir().mkpath(path);
}

bool Berry::renameFile(QString path, const QString &newName)
{
    NORMALIZE_PATH(path);
    return QFile::rename(path, QFileInfo(path).dir().path()+"/"+newName);
}

bool Berry::fileExists(QString path)
{
    NORMALIZE_PATH(path)
    return QFile::exists(path);
}

bool Berry::copyFile(QString src, QString dst, bool allow_delete)
{
    NORMALIZE_PATH(src)
    NORMALIZE_PATH(dst)
    if( fileExists(dst) )
    {
        if( allow_delete )
            QFile::remove(dst);
        else
            return false;
    }

    return QFile::copy(src,dst);
}

void Berry::pasteClipboardFiles(QString dst)
{
    NORMALIZE_PATH(dst);

    const QMimeData *mime = QGuiApplication::clipboard()->mimeData();
    if( !mime )
        return;

    const QList<QUrl> & urls = mime->urls();
    foreach( const QUrl & url, urls )
    {
        QString dst_path = dst;
        if( QFileInfo(dst_path).isDir() )
            dst_path = dst + "/" + QFileInfo(url.toLocalFile()).fileName();

        if( mime->data( "x-special/gnome-copied-files").left(4) == "cut\n" ||
            mime->data( "application/x-kde-cutselection") == "1" )
            QFile::rename(url.toLocalFile(),dst_path);
        else
            QFile::copy(url.toLocalFile(),dst_path);
    }
}

void Berry::setWallpaper(QString file)
{
    NORMALIZE_PATH(file)
    switch( p->viewer->desktopTools()->desktopSession() )
    {
    case AsemanDesktopTools::Mac:
        break;

    case AsemanDesktopTools::Windows:
        break;

    case AsemanDesktopTools::Kde:
        break;

    case AsemanDesktopTools::Unity:
    case AsemanDesktopTools::GnomeFallBack:
    case AsemanDesktopTools::Gnome:
    {
        QString command = "dconf";
        QStringList args;
        args << "write" << "/org/gnome/desktop/background/picture-uri" << QString("'file://%1'").arg(file);

        QProcess::startDetached(command,args);
    }
        break;
    }
}

void Berry::setClipboardText(const QString &text)
{
    QGuiApplication::clipboard()->setText(text);
}

void Berry::setCopyClipboardUrl(const QStringList &paths)
{
    QList<QUrl> urls;
    QString data = "copy";

    foreach( const QString & p, paths ) {
        QUrl url = QUrl::fromLocalFile(p);
        urls << url;
        data += "\nfile://" + url.toLocalFile();
    }

    QMimeData *mimeData = new QMimeData();
    mimeData->setUrls( urls );
    mimeData->setData( "x-special/gnome-copied-files", data.toUtf8() );

    QGuiApplication::clipboard()->setMimeData(mimeData);
}

void Berry::setCutClipboardUrl(const QStringList &paths)
{
    QList<QUrl> urls;

    QString data;
    foreach( const QString & p, paths ) {
        QUrl url = QUrl::fromLocalFile(p);
        urls << url;
        data += "\nfile://" + url.toLocalFile();
    }
    data.remove(0,1);

    QMimeData *mimeData = new QMimeData();
//    mimeData->setUrls( urls );
    mimeData->setData( "x-special/gnome-copied-files", QString("cut\n" + data).toUtf8() );
    mimeData->setData( "text/uri-list", data.toUtf8());
    mimeData->setData( "application/x-kde-cutselection", "1");

    QGuiApplication::clipboard()->setMimeData(mimeData);
}

void Berry::setFullScreen(bool stt)
{
    if( p->fullscreen == stt )
        return;

    p->fullscreen = stt;
    if( p->fullscreen )
#ifdef Q_OS_MAC
        p->mwin->showFullScreen();
#else
        p->viewer->showFullScreen();
#endif
    else
#ifdef Q_OS_MAC
        p->mwin->showNormal();
#else
        p->viewer->showNormal();
#endif

    emit fullScreenChanged();
    emit thumbnailBarChanged();
}

bool Berry::fullScreen() const
{
    return p->fullscreen;
}

void Berry::setHighContrast(bool stt)
{
    if( p->highContrast == stt )
        return;

    p->highContrast = stt;
    p->settings->setValue("General/highContrast",stt);
    emit highContrastChanged();
}

bool Berry::highContrast() const
{
    return p->highContrast;
}

void Berry::setHighGamma(bool stt)
{
    if( p->highGamma == stt )
        return;

    p->highGamma = stt;
    p->settings->setValue("General/highGamma",stt);
    emit highGammaChanged();
}

bool Berry::highGamma() const
{
    return p->highGamma;
}

void Berry::setHighBright(bool stt)
{
    if( p->highBright == stt )
        return;

    p->highBright = stt;
    p->settings->setValue("General/highBright",stt);
    emit highBrightChanged();
}

bool Berry::highBright() const
{
    return p->highBright;
}

void Berry::setThumbnailBar(bool stt)
{
    if( p->fullscreen )
        setFcrThumbnailBar(stt);
    else
        setNrmlThumbnailBar(stt);
}

bool Berry::thumbnailBar() const
{
    if( p->fullscreen )
        return fcrThumbnailBar();
    else
        return nrmlThumbnailBar();
}

void Berry::setFcrThumbnailBar(bool stt)
{
    if( p->fcrThumbnailBar == stt )
        return;

    p->fcrThumbnailBar = stt;
    p->settings->setValue("General/fcrThumbnailBar",stt);

    emit fcrThumbnailBarChanged();
    if( p->fullscreen )
        emit thumbnailBarChanged();
}

bool Berry::fcrThumbnailBar() const
{
    return p->fcrThumbnailBar;
}

void Berry::setNrmlThumbnailBar(bool stt)
{
    if( p->nrmlThumbnailBar == stt )
        return;

    p->nrmlThumbnailBar = stt;
    p->settings->setValue("General/nrmlThumbnailBar",stt);

    emit nrmlThumbnailBarChanged();
    if( !p->fullscreen )
        emit thumbnailBarChanged();
}

bool Berry::nrmlThumbnailBar() const
{
    return p->nrmlThumbnailBar;
}

void Berry::setCurrentLanguage(const QString &lang)
{
    if( p->currentLanguage == lang )
        return;

    QGuiApplication::removeTranslator(p->translator);
    p->translator->load(p->languages.value(lang).toString(),"languages");
    QGuiApplication::installTranslator(p->translator);

    p->currentLanguage = lang;
    p->settings->setValue("General/currentLanguage",lang);

    emit currentLanguageChanged();
}

QString Berry::currentLanguage() const
{
    return p->currentLanguage;
}

QStringList Berry::languages() const
{
    return p->languages.keys();
}

void Berry::start()
{
    p->icon_provider = new IconProvider();
    p->handler_provider = new PathHandlerImageProvider();
    p->thumbnail_loader = new ThumbnailLoader(this);
    p->encrypter = new FileEncrypter(this);
    p->pass_manager = new PasswordManager(this);

    p->viewer = new AsemanQuickView(AsemanQuickView::AllExceptLogger);
    p->viewer->engine()->rootContext()->setContextProperty( "Window", p->viewer );
    p->viewer->engine()->rootContext()->setContextProperty( "Berry", this );
    p->viewer->engine()->rootContext()->setContextProperty( "ThumbnailLoader", p->thumbnail_loader );
    p->viewer->engine()->rootContext()->setContextProperty( "Encypter", p->encrypter );
    p->viewer->engine()->rootContext()->setContextProperty( "PasswordManager", p->pass_manager );
    p->viewer->engine()->addImageProvider("icon",p->icon_provider);
    p->viewer->engine()->addImageProvider(PATH_HANDLER_NAME,p->handler_provider);
    p->viewer->setSource(QUrl("qrc:/qml/Berry/main.qml"));
    p->viewer->resize( p->settings->value("window/size",QSize(960,600)).toSize() );
    p->viewer->show();

#ifdef Q_OS_MAC
    const QSize &dsize = QApplication::desktop()->screenGeometry().size();

    QWidget *containter = QWidget::createWindowContainer(p->viewer);
    containter->setWindowFlags(Qt::Widget);

    p->mwin = new QMainWindow();
    p->mwin->addToolBar( new QToolBar() );
    p->mwin->setUnifiedTitleAndToolBarOnMac(true);
    p->mwin->resize( p->viewer->size() );
    p->mwin->move( dsize.width()/2-p->viewer->width()/2, dsize.height()/2-p->viewer->height()/2 );
    p->mwin->installEventFilter(this);
    p->mwin->show();

    QWidget *wgt = new QWidget(p->mwin);
    QHBoxLayout *layout = new QHBoxLayout(wgt);
    layout->setContentsMargins(0,0,0,0);
    layout->addWidget(containter);

    wgt->resize(p->mwin->size());
    wgt->show();
#else
#endif

#ifdef Q_OS_WIN
    QtWin::enableBlurBehindWindow(p->viewer);
    QtWin::extendFrameIntoClientArea(p->viewer,-1,-1,-1,-1);
#endif

    connect( p->viewer, SIGNAL(heightChanged(int)), SLOT(windowSizeChanged()) );
    connect( p->viewer, SIGNAL(widthChanged(int)) , SLOT(windowSizeChanged()) );

    p->initialized = true;
    emit initializedChanged();
}

void Berry::windowSizeChanged()
{
    p->settings->setValue("window/size",p->viewer->size());
}

void Berry::init_languages()
{
    QString locales_path = QCoreApplication::applicationDirPath() + "/files/translations/";
    if( !QFile::exists(locales_path) )
        locales_path = QFileInfo(QCoreApplication::applicationDirPath() + "/../share/berry/files/translations/").filePath();

    QDir dir(locales_path);
    QStringList languages = dir.entryList( QDir::Files );
    if( !languages.contains("lang-en.qm") )
        languages.prepend("lang-en.qm");

    for( int i=0 ; i<languages.size() ; i++ )
     {
         QString locale_str = languages[i];
             locale_str.truncate( locale_str.lastIndexOf('.') );
             locale_str.remove( 0, locale_str.indexOf('-') + 1 );

         QLocale locale(locale_str);

         QString  lang = QLocale::languageToString(locale.language());
         QVariant data = locales_path + "/" + languages[i];

         p->languages.insert( lang, data );
         p->locales.insert( lang , locale );

         if( lang == p->settings->value("General/language","English").toString() )
             setCurrentLanguage( lang );
    }
}

bool Berry::eventFilter(QObject *o, QEvent *e)
{
#ifdef Q_OS_MAC
    if( o == p->mwin )
    {
        switch( static_cast<int>(e->type()) )
        {
        case QEvent::Resize:
            p->viewer->resize(p->mwin->size());
            break;
        }
    }
#endif
    return QObject::eventFilter(o,e);
}

Berry::~Berry()
{
#ifdef Q_OS_MAC
    delete p->mwin;
#else
    if( p->viewer )
        delete p->viewer;
#endif

    delete p;
}

