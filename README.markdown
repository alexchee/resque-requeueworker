resque-requeueworker
====================

Resque::Plugins::RequeueWorker is an alternative to the standard Worker class. 

This class works by storing the current job and overriding hooks to TERM, INT, 
and KILL signals. If any of the monitored signals are received, the worker will 
recreate the job and shutdown the worker. The original worker only shutdowns 
the worker and the job is lost if the worker does not complete it.

This is original designed for EC2 spot instances where 
machines could suddenly terminate and sends these signals to the workers.

Copyright
---------

Copyright (c) 2011 Alex Chee. See LICENSE for details.