# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-hackernews

CONFIG += sailfishapp

SOURCES += \
    src/harbour-hackernews.cpp

OTHER_FILES += \
    harbour-hackernews.desktop \
    harbour-hackernews.png \
    qml/cover/CoverPage.qml \
    qml/harbour-hackernews.qml \
    qml/pages/FirstPage.qml \
    qml/pages/ShowStory.qml \
    translations/*.ts \


# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-HackerNews-de.ts

DISTFILES += \
    qml/NewsItem.qml \
    qml/delegates/CommentItem.qml \
    qml/delegates/StoryItem.qml \
    qml/pages/ShowComment.qml \
    rpm/harbour-hackernews.yaml \
    rpm/harbour-hackernews.changes.in

