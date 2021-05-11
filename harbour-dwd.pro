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
TARGET = harbour-dwd
CONFIG += sailfishapp

SOURCES += \
    src/harbour-dwd.cpp

DISTFILES += \
    qml/delegates/LocationItem.qml \
    qml/pages/* \
    qml/pages/* \
    qml/svg/* \
    qml/png/* \
    qml/js/* \
    rpm/harbour-dwd.spec \
    rpm/harbour-dwd.yaml \
    rpm/harbour-dwd.changes.in

OTHER_FILES += \
    harbour-dwd.desktop \
    translations/*.ts \


# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-dwd-de.ts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172
