#!/bin/sh

### BEGIN INIT INFO
# Provides:		tcsd trousers
# Required-Start:	$local_fs $remote_fs $network
# Required-Stop:	$local_fs $remote_fs $network
# Should-Start:
# Should-Stop:
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	starts tcsd
# Description:		tcsd belongs to the TrouSerS TCG Software Stack
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/tcsd
NAME=tcsd
DESC="Trusted Computing daemon"
USER="root"

test -x "${DAEMON}" || exit 0

# Read configuration variable file if it is present
# shellcheck disable=SC1090
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

case "${1}" in
	start)
		echo "Starting $DESC: "

    # If TPM chip has not been discovered, probe the chip here
	    for file in /dev/tpm*
		do
		  if [ ! -e "$file" ]
		  then
      # Finally, register the device and install the driver
            # shellcheck disable=SC1091
            . /usr/local/bin/openbmc-utils.sh
            i2c_device_add 7 0x20 tpm_i2c_infineon
          fi
		done

    # Additionally, Generate symlink to tpm0 or tpm1, so that tcsd can use it
    rm -f /dev/tpm
		if [ -e /dev/tpm0 ]
    then
      ln -s /dev/tpm0 /dev/tpm
    else
      ln -s /dev/tpm1 /dev/tpm
    fi
                # shellcheck disable=SC2086
		start-stop-daemon --start --quiet --oknodo --pidfile /var/run/${NAME}.pid --user ${USER} --chuid ${USER} --exec ${DAEMON} -- ${DAEMON_OPTS}
		RETVAL="$?"
		echo "$NAME."
		[ "$RETVAL" = 0 ] && pidof $DAEMON > /var/run/${NAME}.pid
		exit $RETVAL
		;;

	stop)
		echo "Stopping $DESC: "

		start-stop-daemon --stop --quiet --oknodo --pidfile /var/run/${NAME}.pid --user ${USER} --exec ${DAEMON}
		RETVAL="$?"
                echo  "$NAME."
		rm -f /var/run/${NAME}.pid
		exit $RETVAL
		;;

	restart|force-reload)
		"${0}" stop
		sleep 1
		"${0}" start
		exit $?
		;;
	*)
		echo "Usage: ${NAME} {start|stop|restart|force-reload|status}" >&2
		exit 3
		;;
esac

exit 0
