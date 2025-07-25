#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   lib.sh of /CoreOS/tuned/Library/basic
#   Description: Library for tuned
#   Author: Robin Hack <rhack@redhat.com>
#   Author: Branislav Blaskovic <bblaskov@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2015 Red Hat, Inc.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   library-prefix = basic
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 NAME

tuned/basic - Library for tuned

=head1 DESCRIPTION

This is a trivial example of a BeakerLib library. It's main goal
is to provide a minimal template which can be used as a skeleton
when creating a new library. It implements function fileCreate().
Please note, that all library functions must begin with the same
prefix which is defined at the beginning of the library.

=cut

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 VARIABLES

Below is the list of global variables. When writing a new library,
please make sure that all global variables start with the library
prefix to prevent collisions with other libraries.

=over

=item tunedProfileBackupPath

Path where current profile has backup.

=back

=cut

tunedProfileBackupPath="/var/tmp/tunedProfile.backup"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 FUNCTIONS

=head2 tunedProfileBackup

Backups current profile

    tunedProfileBackup

=over

=back

=cut

tunedProfileBackup() {
    current=$(tuned-adm list | grep 'active profile')
    if echo "$current" | grep -q "No current active profile"
    then
        # tuned is off
        echo 'off' > $tunedProfileBackupPath
    else
        echo "$current" | awk -F': ' '{print $2}' > $tunedProfileBackupPath
    fi
    rlLog "Profile '`cat $tunedProfileBackupPath`' was backuped."
}

true <<'=cut'
=pod

=head2 tunedProfileRestore

Restores previous profile

    tunedProfileRestore

=over

=back

=cut

tunedProfileRestore() {
    if [ ! -e $tunedProfileBackupPath ]
    then
        rlLog "You have to run tunedProfileBackup to backup profile first."
        return
    fi
    profile=$(cat $tunedProfileBackupPath)
    if [[ "$profile" = "off" ]]
    then
        rlLog "Turning tuned profile off"
        tuned-adm off
    else
        tuned-adm profile $profile
    fi
    rlLog "Profile '`cat $tunedProfileBackupPath`' was restored."
}

true <<'=cut'
=pod
=head2 tunedAssertCPUsEqual

Check equal number of CPUs - portable way

    tunedAssertCPUsEqual

=over

=back

=cut

tunedAssertCPUsEquals()
{
    local CPUS_NEEDED="$1"
    local ONLINE_CPUS="$(getconf _NPROCESSORS_ONLN)"
    rlAssertEquals "Compare number of cpus" "$CPUS_NEEDED" "$ONLINE_CPUS"
}

true <<'=cut'
=pod

=head2 tunedAssertCPUsGreaterOrEqual

Check greater or equal number of CPUS - portable way

#    tunedAssertCPUsGreaterOrEqual

=over

=back

=cut

tunedAssertCPUsGreaterOrEqual()
{
    local CPUS_NEEDED="$1"
    local ONLINE_CPUS="$(getconf _NPROCESSORS_ONLN)"
    rlAssertGreaterOrEqual "Compare number of CPUs" "$CPUS_NEEDED" "$ONLINE_CPUS"
}

true <<'=cut'
=pod
=head2 tunedDisableSystemdRateLimitingStart

Disable rate limiting of systemd.

    tunedDisableSystemdRateLimitingStart

=over

=back

=cut

tunedDisableSystemdRateLimitingStart()
{
    rlFileBackup --clean /etc/systemd/system.conf.d
    rlRun "mkdir -p /etc/systemd/system.conf.d"
    rlRun "echo -e '[Manager]\nDefaultStartLimitInterval=0' > /etc/systemd/system.conf.d/tuned.conf" 0 "Disable systemd rate limiting"
    rlRun "systemctl daemon-reload"
    return 0
}

true <<'=cut'
=pod
=head2 tunedDisableSystemdRateLimitingEnd

Enable rate limiting of systemd.
It's just restore files and reload daemon so
tunedDisableSystemdRateLimitingStart must be called
before.

    tunedDisableSystemdRateLimitingEnd

=over

=back

=cut

tunedDisableSystemdRateLimitingEnd()
{
    rlFileRestore
    rlRun "systemctl daemon-reload"
    return 0
}


true <<'=cut'
=pod

=head2 tunedGetProfilesBaseDir

Get current profile directory.

    tunedGetProfilesBaseDir

=over

=back

=cut

tunedGetProfilesBaseDir()
{
    BASEPATH="/etc/tuned/"
    if [ -d "/etc/tuned/profiles" ]; then
        BASEPATH="/etc/tuned/profiles/"
    fi

    echo "${BASEPATH}"
}


true <<'=cut'
=pod

=head2 tunedGetUsrProfilesBaseDir

Get current system wide profile directory.

    tunedGetUsrProfilesBaseDir

=over

=back

=cut

tunedGetUsrProfilesBaseDir()
{
    BASEPATH="/usr/lib/tuned/"
    if [ -d "/usr/lib/tuned/profiles" ]; then
        BASEPATH="/usr/lib/tuned/profiles/"
    fi

    echo "${BASEPATH}"
}

true <<'=cut'
=pod

=head2 tunedBackupLogs

Backup logs of tuned into tuned namespace.

    tunedBackupLogs

=over

=back

=cut

tunedBackupLogs()
{
    LOG_FILE_PATH="/var/log/tuned/tuned.log"
    rlServiceStop tuned

    rlFileBackup --namespace tuned "$LOG_FILE_PATH"

    rlServiceRestore tuned
}

true <<'=cut'
=pod

=head2 tunedCleanBackupLogs

Clean and then backup logs of tuned into tuned namespace.

    tunedCleanBackupLogs

=over

=back

=cut

tunedCleanBackupLogs()
{
    LOG_FILE_PATH="/var/log/tuned/tuned.log"
    rlServiceStop tuned

    rlFileBackup --namespace tuned "${LOG_FILE_PATH}"
    rlRun "echo -n > ${LOG_FILE_PATH}"

    rlServiceRestore tuned
}

true <<'=cut'
=pod

=head2 tunedRestoreLogs

Restore logs from tuned namespace.

    tunedRestoreLogs

=over

=back

=cut

tunedRestoreLogs()
{
    LOG_FILE_PATH="/var/log/tuned/tuned.log"
    rlServiceStop tuned

    rlFileRestore --namespace tuned

    rlServiceRestore tuned
}

true <<'=cut'
=pod

=head2 tunedInitEnv

Init test env for tuned in one step.

    tunedInitEnv

=over

=back

=cut

tunedInitEnv()
{
    tunedDisableSystemdRateLimitingStart

    rlServiceStart tuned
    tunedProfileBackup

    tunedCleanBackupLogs
    rlServiceStart tuned
}


true <<'=cut'
=pod

=head2 tunedUnnitEnv

Set back test env for tuned in one step.

    tunedUninitEnv

=over

=back

=cut

tunedUninitEnv()
{
    tunedRestoreLogs

    rlServiceStart tuned
    tunedProfileRestore

    tunedEnableSystemdRateLimitingStart
    rlServiceRestore tuned
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Execution
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 EXECUTION

This library supports direct execution. When run as a task, phases
provided in the PHASE environment variable will be executed.
Supported phases are:

=cut

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Verification
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   This is a verification callback which will be called by
#   rlImport after sourcing the library to make sure everything is
#   all right. It makes sense to perform a basic sanity test and
#   check that all required packages are installed. The function
#   should return 0 only when the library is ready to serve.

basicLibraryLoaded() {
    if rpm=$(rpm -q tuned); then
        rlLogDebug "Library tuned/basic running with $rpm"
        return 0
    else
        rlLogError "Package tuned not installed"
        return 1
    fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Authors
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 AUTHORS

=over

=item *

Robin Hack <rhack@redhat.com>
Branislav Blaskovic <bblaskov@redhat.com>

=back

=cut
