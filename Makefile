##
# Apple wrapper Makefile for jabberd
##

PROJECT_NAME=jabberd
PROJECT_VERSION=1.4
PROJECT_DIR=$(PROJECT_NAME)-$(PROJECT_VERSION)

#
# Set up our variables
#

SILENT=@
ECHO=echo
CP=cp
RM=rm
MV=mv
MKDIR=mkdir
RANLIB=ranlib
ETCDIR=/private/etc
SHAREDIR=/usr/share/man
OBJROOT=$(PWD)
override SRCROOT=$(OBJROOT)
override BUILDROOT=$(OBJROOT)/build
GNUTAR=gnutar
CONFIG_OPTS=--enable-ssl
CFLAGS=$(RC_CFLAGS) -I$(BUILDROOT)/usr/local/include
#LDFLAGS += -L$(BUILDROOT)/usr/local/lib
CHOWN=chown
CONFIG_FILE=jabber.xml
CC_PRINT_OPTIONS_FILE=$(SYMROOT)/print_options_file

# exports for autconf
ACLOCAL=/usr/bin/aclocal
AMTAR=/usr/bin/tar
AUTOCONF=/usr/bin/autoconf
AUTOHEADER=/usr/bin/autoheader
AUTOMAKE=/usr/bin/automake
PREFIX=$(BUILDROOT)
EXEC_PREFIX=$(BUILDROOT)/usr/local

ac_cv_path_PKG_CONFIG=$(BUILDROOT)/usr/local/bin/pkg-config
ac_cv_header_libintl_h=$(BUILDROOT)/usr/local/include
ac_check_lib_save_LIBS=$(BUILDROOT)/usr/local/lib
ac_cv_path_MSGFMT=$(BUILDROOT)/usr/local/bin/msgfmt
ac_cv_lib_intl_dcgettext=$(BUILDROOT)/usr/local/lib/dcgettext

# Use this for feature complete.
SHIP_DEFAULT_FILE_ACCESS=0640

# Use this for feature complete.
SHIP_DEFAULT_ACCESS=0750

# Setup Profiler Permissions
SERVER_SETUP_EXEC=0755

# We need a valid jabber user, we don't have one yet.
DO_NOT_SHIP_DEFAULT_ACCESS=0777

# uid (jabber = 84 )
UID=84

# gid (jabber= 84)
GID=84


DEFAULT_ACCESS=$(SHIP_DEFAULT_ACCESS)
#DEFAULT_ACCESS=$(DO_NOT_SHIP_DEFAULT_ACCESS)

HOME_DIR_ACCESS=$(DEFAULT_ACCESS)
DB_DIR_ACCESS=$(HOME_DIR_ACCESS)
PID_ACCESS=$(DEFAULT_ACCESS)
CONFIG_ACCESS=$(DEFAULT_ACCESS)
JABBER_BIN_DIR=$(DSTROOT)/usr/sbin/
JABBER_XML_DIR=$(DSTROOT)/private/etc/jabber/
JABBER_LIB_DIR=$(DSTROOT)/usr/lib/jabber/
JABBER_LOG_DIR=$(DSTROOT)/private/var/jabber/log/
JABBER_LOG_CONFERENCE_DIR=$(DSTROOT)/private/var/jabber/log/mu-conference/
JABBER_HOME_DIR=$(DSTROOT)/private/var/jabber/
JABBER_DB_DIR=$(DSTROOT)/private/var/jabber/spool/
JABBER_PID_DIR=$(DSTROOT)/private/var/jabber/run/
JABBER_MODULE_DIR=$(DSTROOT)/private/var/jabber/modules/
JABBER_MAN_PAGE_DIR=$(DSTROOT)/usr/share/man/man8/
MODULE_PROXY65_DIR=$(JABBER_MODULE_DIR)proxy65/

# These includes provide the proper paths to system utilities
#

include $(MAKEFILEPATH)/pb_makefiles/platform.make
include $(MAKEFILEPATH)/pb_makefiles/commands-$(OS).make

##
# My GNU Make variables
##

ifndef Project
Project = UNTITLED_PROJECT
endif

ifndef ProjectName
ProjectName = $(Project)
endif

ifneq ($(RC_VERSION),unknown)
Version = RC_VERSION
else
Version := $(shell $(VERS_STRING) -f $(Project) 2>/dev/null | cut -d - -f 2)
ifeq ($(Version),)
Version = 0
endif
endif

Sources        = $(SRCROOT)
## Platforms      = $(patsubst %,%-apple-rhapsody$(RhapsodyVersion),$(RC_ARCHS:ppc=powerpc))
BuildDirectory = $(BUILDROOT)

CC_Archs      = $(RC_ARCHS:%=-arch %)
#CPP_Defines += -DPROJECT_VERSION=\"$(Project)-$(Version)\"

Extra_CC_Flags += $(RC_CFLAGS)

Environment =   CFLAGS="$(CFLAGS)"	\
	       CCFLAGS="$(CXXFLAGS)"	\
	      CXXFLAGS="$(CXXFLAGS)"	\
	       LDFLAGS="$(LDFLAGS)"	\
	      $(Extra_Environment)

export CFLAGS

#autconf exports
export ACLOCAL
export AMTAR
export AUTOCONF
export AUTOHEADER
export AUTOMAKE
export PREFIX
export EXEC_PREFIX
export SRCROOT
export OBJROOT
export BUILDROOT
export DSTROOT

export ac_cv_path_PKG_CONFIG
#export ac_check_lib_save_LIBS
export ac_cv_path_MSGFMT

VPATH=$(Sources)



SETUPDIR=/System/Library/ServerSetup/SetupExtras/
#
# Build rules
#
default:: do_build
#install:: do_clean do_configure do_build do_copy_symbols do_strip do_install do_copy_obj_files do_clean_installed_source
install:: do_clean do_configure do_build do_copy_symbols do_strip do_install do_clean_installed_source
#install:: do_configure do_build do_copy_symbols do_install 
installtest::  do_test_configure do_build do_copy_symbols do_install 
buildtest:: do_build_test do_install 
clean:: do_nothing
configure:: do_configure
installhdrs:: do_installhdrs
installsrc:: do_clean do_installsrc
distclean:: do_clean

## testing
#default:: do_build
#install:: do_build do_install 
#installlocal:: do_configure do_build do_install
#clean:: do_clean
#configure:: do_configure
#installhdrs::  do_clean do_installhdrs
#installsrc::   do_installsrc

do_test_configure:
	mkdir -p $(BUILDROOT)


#
# Custom configuration:
#

do_configure: 
	if test "$(OBJROOT)" != "$(PWD)" ; then \
		ditto . $(OBJROOT) ; \
	fi

	cp -f $(SRCROOT)/libraries/gettext-0.13/autoconf-lib-link/xconfigure $(SRCROOT)/libraries/gettext-0.13/autoconf-lib-link/configure
	cp -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/xconfigure $(SRCROOT)/libraries/gettext-0.13/gettext-tools/configure
	cp -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/xconfigure $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/configure
	cp -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/xconfigure $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/configure
	cp -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/xconfig.h.in $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/config.h.in
	cp -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/xconfig.h.in $(SRCROOT)/libraries/gettext-0.13/gettext-tools/config.h.in

	if test -f $(CC_PRINT_OPTIONS_FILE) ; then \
		echo "found $(CC_PRINT_OPTIONS_FILE)" ;  \
	else \
		mkdir -p $(CC_PRINT_OPTIONS_FILE) ; \
		rmdir $(CC_PRINT_OPTIONS_FILE) ; \
		touch $(CC_PRINT_OPTIONS_FILE) ; \
		echo "created empty print options file" ; \
	fi;  

	if test -d "/tmp" ; then \
		echo "have /tmp" ; \
	else \
		mkdir -p "/tmp" ; \
	fi ; 

	cd $(SRCROOT)/libraries/pkgconfig-0.15.0 && ./configure  --prefix=$(BUILDROOT)/usr/local --exec-prefix=$(BUILDROOT)/usr/local --libdir=$(BUILDROOT)/usr/local/lib --includedir=$(BUILDROOT)/usr/local/include --enable-static
	cd $(SRCROOT)/libraries/expat-1.95.8 && ./configure  --prefix=$(BUILDROOT)/usr/local --exec-prefix=$(BUILDROOT)/usr/local --libdir=$(BUILDROOT)/usr/local/lib --includedir=$(BUILDROOT)/usr/local/include --enable-static=yes --enable-shared=no
	cd $(SRCROOT)/libraries/gettext-0.13 && env DESTDIR=$(BUILDROOT) ./configure   --prefix=$(BUILDROOT)/usr/local --exec-prefix=$(BUILDROOT)/usr/local --libdir=$(BUILDROOT)/usr/local/lib --includedir=$(BUILDROOT)/usr/local/include --enable-static 
	cd $(SRCROOT)/jabberd-src && LDFLAGS="$(LDFLAGS) -L$(BUILDROOT)/usr/local/lib" ./configure $(CONFIG_OPTS) "$(CFLAGS)"
##	cd $(SRCROOT)/libraries/pyOpenSSL-0.5.1 && python setup.py build

do_nothing:

do_copy_symbols:
	# jabberd server in /usr/sbin/
	ditto $(SRCROOT)/jabberd-src/jabberd/jabberd $(SYMROOT)/jabberd

	# the jabber libraries in /usr/lib/jabber
	ditto $(SRCROOT)/jabberd-src/mu-conference-0.6.0/src/mu-conference.so $(SYMROOT)/mu-conference.so
	ditto $(SRCROOT)/jabberd-src/dialback/dialback.so $(SYMROOT)/dialback.so
	ditto $(SRCROOT)/jabberd-src/dnsrv/dnsrv.so $(SYMROOT)/dnsrv.so
	ditto $(SRCROOT)/jabberd-src/jsm/jsm.so $(SYMROOT)/jsm.so
	ditto $(SRCROOT)/jabberd-src/pthsock/pthsock_client.so $(SYMROOT)/pthsock_client.so
	ditto $(SRCROOT)/jabberd-src/jsm_apple/jsm_apple.so $(SYMROOT)/jsm_apple.so
	ditto $(SRCROOT)/jabberd-src/xdb_file/xdb_file.so $(SYMROOT)/xdb_file.so
        
	# the twisted c files     
	ditto $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/internet/cfsupport.so $(SYMROOT)/cfsupport.so
	ditto $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/protocols/_c_urlarg.so $(SYMROOT)/_c_urlarg.so
	ditto $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/runner/portmap.so $(SYMROOT)/portmap.so
	ditto $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/spread/cBanana.so $(SYMROOT)/cBanana.so


do_strip:

	# strip the jabber binary
	strip -u -r -x $(SRCROOT)/jabberd-src/jabberd/jabberd

	# strip the jabber libraries to /usr/lib/jabber
	strip -u -r -x $(SRCROOT)/jabberd-src/mu-conference-0.6.0/src/mu-conference.so
	strip -u -r -x $(SRCROOT)/jabberd-src/dialback/dialback.so
	strip -u -r -x $(SRCROOT)/jabberd-src/dnsrv/dnsrv.so
	strip -u -r -x $(SRCROOT)/jabberd-src/jsm/jsm.so
	strip -u -r -x $(SRCROOT)/jabberd-src/pthsock/pthsock_client.so
	strip -u -r -x $(SRCROOT)/jabberd-src/jsm_apple/jsm_apple.so
	strip -u -r -x $(SRCROOT)/jabberd-src/xdb_file/xdb_file.so

	# strip the twisted c files	
	strip -u -r -x $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/internet/cfsupport.so
	strip -u -r -x $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/protocols/_c_urlarg.so
	strip -u -r -x $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/runner/portmap.so
	strip -u -r -x $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/twisted/spread/cBanana.so

do_install:


	# strip and copy the jabber binary
	mkdir -p $(JABBER_BIN_DIR)
	cp $(SRCROOT)/jabberd-src/jabberd/jabberd $(JABBER_BIN_DIR)

	# copy the jabber.xml configuration file
	mkdir -p $(JABBER_XML_DIR)
	cp $(SRCROOT)/jabberd-src/jabber.xml $(JABBER_XML_DIR)/$(CONFIG_FILE)
	# chmod $(CONFIG_ACCESS) $(JABBER_XML_DIR)
	chmod $(SHIP_DEFAULT_FILE_ACCESS) $(JABBER_XML_DIR)/$(CONFIG_FILE)
	$(CHOWN) $(UID):$(GID) $(JABBER_XML_DIR)/$(CONFIG_FILE)


	# make the default home directory 	
	mkdir -p $(JABBER_HOME_DIR)
	chmod $(HOME_DIR_ACCESS) $(JABBER_HOME_DIR) 
	$(CHOWN) -R $(UID):$(GID) $(JABBER_HOME_DIR)

	# make the db directory (after home dir)
	mkdir -p $(JABBER_DB_DIR)
	chmod $(DB_DIR_ACCESS) $(JABBER_DB_DIR) 
	$(CHOWN) -R $(UID):$(GID) $(JABBER_DB_DIR)

	# make the pid directory
	mkdir -p $(JABBER_PID_DIR)
	chmod $(PID_ACCESS) $(JABBER_PID_DIR) 
	$(CHOWN) -R $(UID):$(GID) $(JABBER_PID_DIR)

	# make the module directory
	mkdir -p $(JABBER_MODULE_DIR)
	chmod $(HOME_DIR_ACCESS) $(JABBER_MODULE_DIR) 
	$(CHOWN) -R $(UID):$(GID) $(JABBER_MODULE_DIR)

	# make the proxy module directory
	mkdir -p $(MODULE_PROXY65_DIR)
	chmod $(HOME_DIR_ACCESS) $(MODULE_PROXY65_DIR)
	$(CHOWN) -R $(UID):$(GID) $(MODULE_PROXY65_DIR)
       
    
    # make the log directory
	mkdir -p $(JABBER_LOG_DIR)
	chmod $(HOME_DIR_ACCESS) $(JABBER_LOG_DIR)
	$(CHOWN) -R $(UID):$(GID) $(JABBER_LOG_DIR)

    # make the muc-conference log directory
	mkdir -p $(JABBER_LOG_CONFERENCE_DIR)
	chmod $(HOME_DIR_ACCESS) $(JABBER_LOG_CONFERENCE_DIR)
	$(CHOWN) -R $(UID):$(GID) $(JABBER_LOG_CONFERENCE_DIR)


	# make the library directory
	mkdir -p $(JABBER_LIB_DIR)
	chmod $(HOME_DIR_ACCESS) $(JABBER_LIB_DIR)
	$(CHOWN) -R $(UID):$(GID) $(JABBER_LIB_DIR)
    
	# copy the jabber libraries to /usr/lib/jabber
	cp $(SRCROOT)/jabberd-src/mu-conference-0.6.0/src/mu-conference.so $(JABBER_LIB_DIR)
	cp $(SRCROOT)/jabberd-src/dialback/dialback.so $(JABBER_LIB_DIR)
	cp $(SRCROOT)/jabberd-src/dnsrv/dnsrv.so $(JABBER_LIB_DIR)
	cp $(SRCROOT)/jabberd-src/jsm/jsm.so $(JABBER_LIB_DIR)
	cp $(SRCROOT)/jabberd-src/pthsock/pthsock_client.so $(JABBER_LIB_DIR)
	cp $(SRCROOT)/jabberd-src/jsm_apple/jsm_apple.so $(JABBER_LIB_DIR)
	cp $(SRCROOT)/jabberd-src/xdb_file/xdb_file.so $(JABBER_LIB_DIR)


	cp $(SRCROOT)/modules/filetransfer/makeargtap $(MODULE_PROXY65_DIR)

   
	#don't stop on the symlink python puts down for site-packages just drop the files in the linked to directory
	#make sure we are using the right privileges
	ditto /Library/Python/2.3/site-packages/ $(DSTROOT)/Library/Python/2.3/site-packages/
	#we don't care about other files and directories
	rm -rf $(DSTROOT)/Library/Python/2.3/site-packages/*
	#move our install to the right location
	mv -f $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages/* $(DSTROOT)/Library/Python/2.3/site-packages/
	#clean up so site-packages doesn't stomp on the symlink of site-packages put down by python
	rmdir $(DSTROOT)/System/Library/Frameworks/Python.framework/Versions/2.3/lib/python2.3/site-packages



	# copy the man page
	mkdir -p $(JABBER_MAN_PAGE_DIR)
	cp -f "$(SRCROOT)"/manpage/jabberd.8 "$(JABBER_MAN_PAGE_DIR)"
   
	# copy the open source support files
	$(MKDIRS) "$(DSTROOT)/usr/local/OpenSourceVersions"
	cp "$(SRCROOT)/ChatServer.plist" "$(DSTROOT)/usr/local/OpenSourceVersions"
 
 do_build:
	# do_build
	cd $(SRCROOT)/libraries/pkgconfig-0.15.0 && make
	cd $(SRCROOT)/libraries/pkgconfig-0.15.0 && make install

	cd $(SRCROOT)/libraries/expat-1.95.8 && make
	cd $(SRCROOT)/libraries/expat-1.95.8 && make install

	cd $(SRCROOT)/libraries/gettext-0.13 && make
	cd $(SRCROOT)/libraries/gettext-0.13 && make install

	cd $(SRCROOT)/libraries/glib-2.4.5 && env CFLAGS="-arch ppc -pipe" CPPFLAGS=-I$(BUILDROOT)/usr/local/include LDFLAGS="-L$(BUILDROOT)/usr/local/lib" ./configure --libdir=$(BUILDROOT)/usr/local/lib --prefix=$(BUILDROOT) --exec-prefix=$(BUILDROOT) --includedir=$(BUILDROOT)/usr/local/include --enable-static --disable-shared 	
	cd $(SRCROOT)/libraries/glib-2.4.5 && env  CFLAGS="-arch ppc -arch=i386 -pipe" DESTDIR="" LDFLAGS="-L$(BUILDROOT)/usr/local/lib" make
	cd $(SRCROOT)/libraries/glib-2.4.5 && make install

	cd $(SRCROOT)/jabberd-src/mu-conference-0.6.0 && make

	cd $(SRCROOT)/libraries/Twisted-1.3.0   && python setup.py bdist_dumb
	cd $(SRCROOT)/modules/filetransfer/proxy65 && python setup.py bdist_dumb
	cd $(SRCROOT)/jabberd-src && make LDFLAGS="$(LDFLAGS) -L$(BUILDROOT)/usr/local/lib"

	cd $(SRCROOT)/libraries/Twisted-1.3.0/dist/ && cp Twisted*.tar.gz $(DSTROOT)/Twisted-1.3.0.tar.gz
	gunzip $(DSTROOT)/Twisted-1.3.0.tar.gz 
	tar -xvf $(DSTROOT)/Twisted-1.3.0.tar -C $(DSTROOT)/
	rm $(DSTROOT)/Twisted-1.3.0.tar

	cd $(SRCROOT)/modules/filetransfer/proxy65/dist/ && cp Proxy*.tar.gz  $(DSTROOT)/Proxy65-1.0.0.tar.gz
	gunzip $(DSTROOT)/Proxy65-1.0.0.tar.gz
	tar -xvf $(DSTROOT)/Proxy65-1.0.0.tar -C $(DSTROOT)/
	rm $(DSTROOT)/Proxy65-1.0.0.tar


do_build_test:
	# do_build_test
	 
do_installhdrs:
	echo "installhdrs: no headers to install, skipping"

do_installsrc:
	make -f ./Makefile.installsrc installsrc $(MAKEFLAGS) 

do_clean:
	if test -f $(CC_PRINT_OPTIONS_FILE) ; then \
		echo "found $(CC_PRINT_OPTIONS_FILE)" ;	 \
	else \
		mkdir -p $(CC_PRINT_OPTIONS_FILE) ; \
		rmdir $(CC_PRINT_OPTIONS_FILE) ; \
		touch $(CC_PRINT_OPTIONS_FILE) ; \
		echo "created empty print options file" ; \
	fi;  

	if test -d "/tmp" ; then \
		echo "have /tmp" ; \
	else \
		mkdir -p "/tmp" ; \
	fi ; 


	#clean up caches
	rm -f ./libraries/pkgconfig-0.15.0/config.status
	rm -f ./libraries/pkgconfig-0.15.0/config.cache
	rm -f ./libraries/gettext-0.13/config.status
	rm -f ./libraries/gettext-0.13/config.cache
	rm -f ./libraries/gettext-0.13/autoconf-lib-link/config.status
	rm -f ./libraries/gettext-0.13/autoconf-lib-link/config.cache
	rm -f ./libraries/gettext-0.13/gettext-runtime/config.status
	rm -f ./libraries/gettext-0.13/gettext-runtime/config.cache
	rm -f ./libraries/gettext-0.13/gettext-runtime/libasprintf/config.status
	rm -f ./libraries/gettext-0.13/gettext-runtime/libasprintf/config.cache
	rm -f ./libraries/gettext-0.13/gettext-tools/config.status
	rm -f ./libraries/gettext-0.13/gettext-tools/config.cache
	rm -f ./libraries/gettext-0.13/gettext-tools/config.cache

	#remove local builds and configure and make created and modified files
	rm -f ./libraries/gettext-0.13/gettext-tools/config.h.in~
	rm -f ./libraries/gettext-0.13/gettext-tools/config.h.in
	rm -f ./libraries/gettext-0.13/gettext-runtime/libasprintf/config.h.in~
	rm -f ./libraries/gettext-0.13/gettext-runtime/libasprintf/config.h.in
	rm -f ./libraries/gettext-0.13/gettext-tools/po/Makefile.in



	rm -f ./libraries/gettext-0.13/gettext-tools/lib/Makefile 
	rm -f ./libraries/gettext-0.13/gettext-tools/lib/javacomp.sh   
	rm -f ./libraries/gettext-0.13/gettext-tools/lib/javaexec.sh
	rm -f ./libraries/gettext-0.13/gettext-tools/libuniname/Makefile   
	rm -f ./libraries/gettext-0.13/gettext-tools/m4/Makefile 

	rm -f ./libraries/gettext-0.13/gettext-tools/m4/Makefile 
	rm -f ./libraries/gettext-0.13/gettext-tools/po/Makefile 
	rm -f ./libraries/gettext-0.13/gettext-tools/po/POTFILES    
	rm -f ./libraries/gettext-0.13/gettext-tools/projects/Makefile  

	rm -f ./libraries/gettext-0.13/gettext-tools/src/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/src/user-email

	rm -f ./jabberd-src/platform-settings
	rm -f ./jabberd-src/jabberd/pth-1.4.0/Makefile
	rm -f ./jabberd-src/jabberd/pth-1.4.0/config.cache
	rm -f ./jabberd-src/jabberd/pth-1.4.0/config.log
	rm -f ./jabberd-src/jabberd/pth-1.4.0/config.status
	rm -f ./jabberd-src/jabberd/pth-1.4.0/libtool
	rm -f ./jabberd-src/jabberd/pth-1.4.0/pth.h
	rm -f ./jabberd-src/jabberd/pth-1.4.0/pth_acmac.h
	rm -f ./jabberd-src/jabberd/pth-1.4.0/pth-config
	rm -f ./jabberd-src/jabberd/pth-1.4.0/pth_acdef.h

	rm -rf ./libraries/pyOpenSSL-0.5.1/build
	rm -rf ./libraries/pyOpenSSL-0.5.1/dist
	rm -rf ./libraries/Twisted-1.3.0/build
	rm -rf ./libraries/Twisted-1.3.0/dist
	rm -rf ./modules/filetransfer/proxy65/build
	rm -rf ./modules/filetransfer/proxy65/dist

	rm -rf ./build

	rm -f ./libraries/pkgconfig-0.15.0/glib-1.2.8/glibconfig-sysdefs.h
	rm -f ./libraries/pkgconfig-0.15.0/glib-1.2.8/glibconfig-sysdefs.h
	rm -f ./jabberd-src/jabberd/pth-1.4.0/config.cache

	rm -f ./jabberd-src/jabberd/pth-1.4.0/pth_acdef.h 
	rm -f ./libraries/Twisted-1.3.0/twisted/__init__.pyc
	rm -f ./libraries/Twisted-1.3.0/twisted/copyright.pyc
	rm -f ./libraries/Twisted-1.3.0/twisted/python/__init__.pyc
	rm -f ./libraries/Twisted-1.3.0/twisted/python/compat.pyc

	rm -f ./libraries/gettext-0.13/aclocal.m4

	rm -f ./libraries/gettext-0.13/gettext-runtime/man/Makefile
	rm -f ./libraries/gettext-0.13/gettext-runtime/doc/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/doc/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/examples/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/examples/po/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/man/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/misc/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/tests/Makefile

	rm -f ./libraries/gettext-0.13/autoconf-lib-link/configure
	rm -f ./libraries/gettext-0.13/gettext-tools/configure
	rm -f ./libraries/gettext-0.13/gettext-runtime/configure
	rm -f ./libraries/gettext-0.13/gettext-runtime/libasprintf/configure

	rm -f ./libraries/gettext-0.13/autoconf-lib-link/aclocal.m4
	rm -f ./libraries/gettext-0.13/gettext-runtime/libasprintf/aclocal.m4
	rm -f ./libraries/gettext-0.13/gettext-runtime/man/x-to-1
	rm -f ./libraries/gettext-0.13/gettext-runtime/src/Makefile
	rm -f ./libraries/gettext-0.13/gettext-tools/aclocal.m4  
	rm -f ./libraries/gettext-0.13/gettext-tools/man/x-to-1 

	rm -f ./libraries/gettext-0.13/gettext-tools/examples/installpaths
	rm -f ./libraries/gettext-0.13/gettext-tools/misc/gettextize
	rm -f ./libraries/gettext-0.13/gettext-tools/misc/autopoint

	rm -rf ./libraries/gettext-0.13/autoconf-lib-link/autom4te.cache
	rm -rf ./libraries/gettext-0.13/gettext-runtime/autom4te.cache
	rm -rf ./libraries/gettext-0.13/gettext-runtime/libasprintf/autom4te.cache
	rm -rf ./libraries/gettext-0.13/gettext-tools/autom4te.cache

	rm -rf ./jabberd-src/jabberd/pth-1.4.0/Makefile
	rm -rf ./libraries/gettext-0.13/autoconf-lib-link/aclocal.m4
	rm -rf ./libraries/gettext-0.13/autoconf-lib-link/configure
	rm -rf ./libraries/gettext-0.13/gettext-runtime/configure   
	rm -rf ./libraries/gettext-0.13/gettext-runtime/intl-java/Makefile
	rm -rf ./libraries/gettext-0.13/gettext-runtime/lib/Makefile
	rm -rf ./libraries/gettext-0.13/gettext-runtime/lib/javacomp.sh
	rm -rf ./libraries/gettext-0.13/gettext-runtime/libasprintf/aclocal.m4
	rm -rf ./libraries/gettext-0.13/gettext-runtime/libasprintf/config.h.in
	rm -rf ./libraries/gettext-0.13/gettext-runtime/libasprintf/configure
	rm -rf ./libraries/gettext-0.13/gettext-runtime/m4/Makefile
	rm -rf ./libraries/gettext-0.13/gettext-runtime/po/Makefile
	rm -rf ./libraries/gettext-0.13/gettext-runtime/po/Makefile.in
	rm -rf ./libraries/gettext-0.13/gettext-runtime/po/POTFILES
	rm -rf ./libraries/gettext-0.13/gettext-runtime/aclocal.m4
	rm -rf ./libraries/gettext-0.13/gettext-tools/aclocal.m4
	rm -rf ./libraries/gettext-0.13/gettext-tools/config.h.in
	rm -rf ./libraries/gettext-0.13/gettext-tools/configure
	rm -rf ./libraries/pkgconfig-0.15.0/glib-1.2.8/glib.spec
	rm -rf ./libraries/pkgconfig-0.15.0/glib-1.2.8/xconfig.cache
	rm -rf ./libraries/pkgconfig-0.15.0/glib-1.2.8/glibconfig.h

	rm -f ./.afpDeleted*
	rm -f ./*/.afpDeleted*
	rm -f ./*/*/.afpDeleted*
	rm -f ./*/*/*/.afpDeleted*
	rm -f ./*/*/*/*/.afpDeleted*
	rm -f ./*/*/*/*/*/.afpDeleted*

# following was to untar original source
#	rm -rf ./libraries/pyOpenSSL-0.5.1
#	rm -rf ./libraries/Twisted-1.3.0
#	rm -rf ./modules/filetransfer/proxy65
#	tar -xvf ./libraries/pyOpenSSL-0.5.1.tar -C ./libraries/ --exclude pyOpenSSL-0.5.1/doc
#	tar -xvf ./libraries/Twisted-1.3.0.tar -C ./libraries/ --exclude Twisted-1.3.0/doc --exclude Twisted-1.3.0/sandbox
#	tar -xvf ./modules/filetransfer/proxy65-1-1.0.tar -C ./modules/filetransfer/

do_clean_installed_source:
	# do a standard clean and then remove some stuff that it
	# misses, most of which belongs to pth
	cd $(SRCROOT)/libraries/gettext-0.13 && make distclean
	cd $(SRCROOT)/libraries/pkgconfig-0.15.0 && make distclean
	cd $(SRCROOT)/libraries/glib-2.4.5 && make distclean

	cd $(SRCROOT)/jabberd-src && make clean
	cd $(SRCROOT)/jabberd-src/mu-conference-0.6.0 && make clean

	rm -f $(SRCROOT)/jabberd-src/platform-settings
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/Makefile
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/config.log
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/config.status
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/libtool
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/pth.h
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/pth_acmac.h
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/pth-config
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/pth_acdef.h
	rm -f $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/config.cache

##	cd $(SRCROOT)/libraries/pyOpenSSL-0.5.1 && python setup.py clean
	cd $(SRCROOT)/libraries/Twisted-1.3.0   && python setup.py clean
	cd $(SRCROOT)/modules/filetransfer/proxy65 && python setup.py clean
	rm -rf $(SRCROOT)/libraries/pyOpenSSL-0.5.1/build
	rm -rf $(SRCROOT)/libraries/pyOpenSSL-0.5.1/dist
	rm -rf $(SRCROOT)/libraries/Twisted-1.3.0/build
	rm -rf $(SRCROOT)/libraries/Twisted-1.3.0/dist
	rm -rf $(SRCROOT)/modules/filetransfer/proxy65/build
	rm -rf $(SRCROOT)/modules/filetransfer/proxy65/dist
	rm -rf $(SRCROOT)/build

	rm -f $(SRCROOT)/libraries/pkgconfig-0.15.0/glib-1.2.8/glibconfig-sysdefs.h
	rm -f $(SRCROOT)/libraries/pkgconfig-0.15.0/glib-1.2.8/xconfig.cache



	rm -f ./jabberd-src/jabberd/pth-1.4.0/pth_acdef.h 
	rm -f $(SRCROOT)/libraries/Twisted-1.3.0/twisted/__init__.pyc
	rm -f $(SRCROOT)/libraries/Twisted-1.3.0/twisted/copyright.pyc
	rm -f $(SRCROOT)/libraries/Twisted-1.3.0/twisted/python/__init__.pyc
	rm -f $(SRCROOT)/libraries/Twisted-1.3.0/twisted/python/compat.pyc

	rm -f $(SRCROOT)/libraries/gettext-0.13/aclocal.m4

	rm -rf $(SRCROOT)/libraries/gettext-0.13/autoconf-lib-link/autom4te.cache
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/autom4te.cache
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/autom4te.cache
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-tools/autom4te.cache

	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/man/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/doc/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/src/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/doc/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/examples/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/examples/po/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/man/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/misc/Makefile
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/tests/Makefile

	rm -f $(SRCROOT)/libraries/gettext-0.13/autoconf-lib-link/configure
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/configure
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/configure
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/configure

	rm -f $(SRCROOT)/libraries/gettext-0.13/autoconf-lib-link/aclocal.m4
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/aclocal.m4
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/man/x-to-1
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/aclocal.m4  
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/man/x-to-1 

	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/examples/installpaths
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/misc/gettextize
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/misc/autopoint
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/config.h.in
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/config.h.in
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/config.h.in~
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/config.h.in~
	rm -f $(SRCROOT)/libraries/gettext-0.13/gettext-tools/po/Makefile.in

	rm -rf $(SRCROOT)/jabberd-src/jabberd/pth-1.4.0/Makefile
	rm -rf $(SRCROOT)/libraries/gettext-0.13/autoconf-lib-link/aclocal.m4
	rm -rf $(SRCROOT)/libraries/gettext-0.13/autoconf-lib-link/configure
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/configure   
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/intl-java/Makefile
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/lib/Makefile
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/lib/javacomp.sh
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/aclocal.m4
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/config.h.in
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/libasprintf/configure
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/m4/Makefile
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/po/Makefile
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/po/Makefile.in
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/po/POTFILES
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-runtime/aclocal.m4
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-tools/aclocal.m4
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-tools/config.h.in
	rm -rf $(SRCROOT)/libraries/gettext-0.13/gettext-tools/configure
	rm -rf $(SRCROOT)/libraries/pkgconfig-0.15.0/glib-1.2.8/glib.spec
	rm -rf $(SRCROOT)/libraries/pkgconfig-0.15.0/glib-1.2.8/xconfig.cache
	rm -rf $(SRCROOT)/libraries/pkgconfig-0.15.0/glib-1.2.8/glibconfig.h

#	rm -rf $(SRCROOT)/include
#	rm -rf $(SRCROOT)/info
#	rm -rf $(SRCROOT)/share
#	rm -rf $(SRCROOT)/usr
#	rm -rf $(SRCROOT)/libraries/glib-2.4.5/glib/.deps


do_copy_obj_files:
	# copy all of the object files into the OBJROOT folder for safe-keeping by B&I
	cd $(SRCROOT)/jabberd-src/ && find * -name \*.o -exec mkdir -p $(OBJROOT)/{} \; -exec rmdir $(OBJROOT)/{} \; -exec mv {} $(OBJROOT)/{} \;
	cd $(SRCROOT)/libraries/ && find * -name \*.o -exec mkdir -p $(OBJROOT)/{} \; -exec rmdir $(OBJROOT)/{} \; -exec mv {} $(OBJROOT)/{} \;
	cd $(SRCROOT)/modules/ && find * -name \*.o -exec mkdir -p $(OBJROOT)/{} \; -exec rmdir $(OBJROOT)/{} \; -exec mv {} $(OBJROOT)/{} \;