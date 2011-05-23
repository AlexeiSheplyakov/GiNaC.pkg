#!/bin/sh
set -e
case "`uname -s`" in
	[Ll]inux)
		J="$(grep -e '^processor' /proc/cpuinfo | wc -l)"
		if [ ${J} -le 0 ]; then
			# /proc not mounted or something
			J=1
		fi
		need_winesetup="yes"
		;;
	cygwin*|[Mm]ingw*)
		J=${NUMBER_OF_PROCESSORS}
		;;
	*)
		J=1
		;;
esac

if [ "${need_winesetup}" = "yes" ]; then
	$(dirname $0)/winesetup.sh
fi

exec nice -n19 mispipe "make -j2 2>&1" "tee build.log"
