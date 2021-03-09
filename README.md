# NAME

tuned/basic - Library for tuned

# DESCRIPTION

This is a trivial example of a BeakerLib library. It's main goal
is to provide a minimal template which can be used as a skeleton
when creating a new library. It implements function fileCreate().
Please note, that all library functions must begin with the same
prefix which is defined at the beginning of the library.

# VARIABLES

Below is the list of global variables. When writing a new library,
please make sure that all global variables start with the library
prefix to prevent collisions with other libraries.

- tunedProfileBackupPath

    Path where current profile has backup.

# FUNCTIONS

## tunedProfileBackup

Backups current profile

    tunedProfileBackup

## tunedProfileRestore

Restores previous profile

    tunedProfileRestore

## tunedAssertCPUsEqual

Check equal number of CPUs - portable way

    tunedAssertCPUsEqual

## tunedAssertCPUsGreaterOrEqual

Check greater or equal number of CPUS - portable way

\#    tunedAssertCPUsGreaterOrEqual

# EXECUTION

This library supports direct execution. When run as a task, phases
provided in the PHASE environment variable will be executed.
Supported phases are:

# AUTHORS

- Robin Hack <rhack@redhat.com>
- Branislav Blaskovic <bblaskov@redhat.com>
