# function to test for a lock
# expects the lock file as the first argument
function f_lock_test {

lock_pid_file=$1
# error checking
if [[ ${lock_pid_file} == "" ]]
  then
    echo "`date` - no lock file argument provided -  exiting" >&2
    return 1
fi

if [ -e ${lock_pid_file} ]
        then
                existing_pid=`cat ${lock_pid_file}`
                        if kill -0 &>1 > /dev/null ${existing_pid}
                                then
                                        echo "`date` - Process already running"
                                        exit 1

                                else
                                        rm -f ${lock_pid_file}
                        fi
fi
echo $$  > ${lock_pid_file}

}
