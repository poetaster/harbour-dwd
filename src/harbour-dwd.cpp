/*
  Copyright (C) 2021 Mark Washeim
  Contact: Mark Washeim <blueprint@poetaster.de>

  You may use this file under the terms of GPLv3
*/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif


#include <QGuiApplication>
#include <QLocale>
#include <QQuickView>
#include <QScopedPointer>
#include <QStandardPaths>
#include <QString>
#include <QStringList>
#include <QTranslator>
#include <QtQml>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QString>
#include <QStandardPaths>
#include <QCryptographicHash>
#include <sailfishapp.h>


void migrateLocalStorage()
{

    // The new location of the LocalStorage database
    QDir newDbDir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/de.poetaster/harbour-dwd/QML/OfflineStorage/Databases/");

    if(newDbDir.exists())
        return;

    newDbDir.mkpath(newDbDir.path());

    QString dbname = QString(QCryptographicHash::hash(("harbour-dwd"), QCryptographicHash::Md5).toHex());

    qDebug() << "dbname: " + dbname;

    QString pathOld = "/harbour-dwd/harbour-dwd/QML/OfflineStorage/Databases/";
    QString pathNew = "/de.poetaster/harbour-dwd/QML/OfflineStorage/Databases/";

    // The old LocalStorage database
    QFile oldDb(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +  pathOld + dbname + ".sqlite");
    QFile oldIni(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + pathOld + dbname + ".ini");

    oldDb.copy(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +  pathNew + dbname + ".sqlite");
    oldIni.copy(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + pathNew + dbname + ".ini");

}

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    // first check if we've got the new paths in place
    // this has to be done here, before we assign name below
    migrateLocalStorage();

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    app->setOrganizationDomain("de.poetaster");
    app->setOrganizationName("de.poetaster"); // needed for Sailjail
    app->setApplicationName("harbour-dwd");

    // install translations, though this is probably automagical, to-do see actual values
    // QLocale::system().name()
    QTranslator *appTranslator = new QTranslator;
    appTranslator->load("harbour-dwd-" + QLocale::system().name(), SailfishApp::pathTo("translations").path());
    app->installTranslator(appTranslator);

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    //view->rootContext()->setContextProperty("dateParser", &dateParser);
    //view->rootContext()->setContextProperty("json", &json);

    view->setSource(SailfishApp::pathTo("qml/harbour-dwd.qml"));
    view->setTitle("German Weath Service");
    view->showFullScreen();

    return app->exec();
}

