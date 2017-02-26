.. _pts_mode:

****************************************************
Running a single point using global data - PTS_MODE
****************************************************

``PTS_MODE`` enables you to run the model using global datasets, but just picking a single point from those datasets and operating on it. 
It can be a very quick way to do fast simulations and get a quick turnaround.

To setup a ``PTS_MODE`` simulation you use the "-pts_lat" and "-pts_lon" arguments to **create_newcase** to give the latitude and longitude of the point you want to simulate for (the code will pick the point on the global grid nearest to the point you give. Here's an example to setup a simulation for the nearest point at 2-degree resolution to Boulder Colorado.
::

   > cd scripts
   > ./create_newcase -case testPTS_MODE -res f19_g16 -compset I1850CRUCLM45BGC -pts_lat 40.0 -pts_lon -105
   > cd testPTS_MODE

   # We make sure the model will start up cold rather than using initial conditions
   > ./xmlchange CLM_FORCE_COLDSTART=on,RUN_TYPE=startup

Then setup, build and run as normal. We make sure initial conditions are NOT used since ``PTS_MODE`` currently CAN NOT run with initial conditions.

.. note:: By default it sets up to run with MPILIB=mpi-serial (in the env_build.xml file) turned on, which allows you to run the model interactively. On some machines this mode is NOT supported and you may need to change it to FALSE before you are able to build.

.. warning:: ``PTS_MODE`` currently does NOT restart nor is it able to startup from global initial condition files. See bugs "1017 and 1025" in the `models/lnd/clm/doc/KnownLimitationss <CLM-URL>`_ file.

.. note:: You can change the point you are simulating for at run-time by changing the values of ``PTS_LAT`` and ``PTS_LON`` in the ``env_run.xml`` file.

==================================
 Running on in a single processor
==================================

Note, that when running with ``PTS_MODE`` the number of processors is automatically set to one. 
When running a single grid point you can only use a single processor. 
You might also want to set the ``env_build.xml`` variable: ``MPILIB=mpi-serial`` to ``TRUE`` so that you can also run interactively without having to use MPI to start up your job.

On many machines, batch queues have a minimum number of nodes or processors that can be used. 
On these machines you may have to change the queue and possibly the time-limits of the job, to get it to run in the batch queue. 
On the NCAR machine, yellowstone, this is done for you automatically, and the "caldera" queue is used for such single-processor simulations. 
Another way to get around this problem is to run the job interactively using ``MPILIB=mpi-serial`` so that you don't submit the job to the batch queue.  
For single point mode you also may want to consider using a smaller workstation or cluster, rather than a super-computer, because you can't take advantage of the multi-processing power of the super-computer anyway.
