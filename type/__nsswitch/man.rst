cdist-type__nsswitch(7)
=======================

NAME
----
cdist-type__nsswitch - manage Name Service Switch database configuration


DESCRIPTION
-----------
This type can be used to manage database configurations in the
:strong:`nsswitch.conf`\ (5) file.

This type does no checking whether your operating system/libc respects the
nsswitch.conf file, this job is up to you.


OPTIONAL PARAMETERS
-------------------
source
   Specify the name of a source for this database (with optional criteria
   appended to the source name in square brackets ``[]``).
   See :strong:`nsswitch.conf`\ (5) for the options supported by your operating
   system.

   Can be used multiple times so specify multiple sources which will be queried
   in the order specified.

   If no sources are given, the database entry will be removed from
   :strong:`nsswitch.conf`\ (5).


EXAMPLES
--------

.. code-block:: sh

   # Configure NSS to query LDAP for users/groups (Linux)
   __nsswitch passwd \
      --source ldap \
      --source files
   __nsswitch group \
      --source ldap \
      --source files
   __nsswitch shadow \
      --source ldap \
      --source files

   # Configure NSS host lookup to include mDNS (using libnss-mdns on Linux)
   # Other OSs may use different source names, e.g. mdns_minimal is called
   # multicast_dns on NetBSD
   __nsswitch hosts \
      --source files \
      --source 'mdns_minimal [NOTFOUND=return]' \
      --source dns


SEE ALSO
--------
:strong:`nsswitch.conf`\ (5)


AUTHORS
-------
| Dennis Camera <dennis.camera--@--riiengineering.ch>


COPYING
-------
Copyright \(C) 2023 Dennis Camera.
You can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.
