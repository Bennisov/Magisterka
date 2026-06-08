FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://platform-top.h file://bsp.cfg"
SRC_URI += "file://user_2025-10-21-05-55-00.cfg \
            file://user_2025-10-21-12-52-00.cfg \
            "

