cdist-type__timezone(7)
=======================

NAME
----
cdist-type__timezone - Configure the system timezone.


DESCRIPTION
-----------
This type creates a symlink (``/etc/localtime``) to the selected
timezone (which should be available in ``/usr/share/zoneinfo``).


REQUIRED PARAMETERS
-------------------
tz
   The name of timezone to set.


OPTIONAL PARAMETERS
-------------------
tzdir
   The directory containing the timezone data files on the target.
   Default: Detected based on OS, usually ``/usr/share/zoneinfo``.


EXAMPLES
--------

.. code-block:: sh

   # Set up Europe/Andorra as our timezone.
   __timezone --tz Europe/Andorra

   # Set up US/Central as our timezone.
   __timezone --tz US/Central

   # Some operating systems (e.g. Debian, RedHat, SuSE) have a separate
   # directory for POSIX timezones (time values interpreted as seconds since
   # the epoch, not counting leap seconds).
   # It can be used by manually specifying the TZDIR.
   __timezone --tz Europe/Vaduz --tzdir /usr/share/zoneinfo/posix


AUTHORS
-------
| Dennis Camera <cdist--@--dtnr.ch>
| Steven Armstrong <steven-cdist--@--armstrong.cc>
| Nico Schottelius <nico-cdist--@--schottelius.org>
| Ramon Salvadó <rsalvado--@--gnuine--dot--com>


COPYING
-------
Copyright \(C) 2012-2022 the `AUTHORS`_.
You can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later
version.
