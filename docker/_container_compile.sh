#!/bin/bash

clear

# THIS one works the same way #
# . config
source config


# # # # # # # # # # # # # # # #

var_start=""; var_end="";
function timer_start() { var_start=$(date +%s); }
function timer_end() { var_end=$(date +%s); }
timer_print()
{
    elapsed=$((var_end - var_start))
    hours=$((elapsed / 3600))
    minutes=$(( (elapsed % 3600) / 60 ))
    seconds=$((elapsed % 60))
    printf "\nProgram          - took: %02d:%02d:%02d\n" $hours $minutes $seconds
}
function env_prep()
{
    create_dir "$DIR_INPUT"
    create_dir "$DIR_BUILD"
    create_dir "$DIR_TARGET"
    create_dir "$DIR_EXTERNAL"
    create_dir "$DIR_LOG"
    create_dir "$DIR_OUTPUT"
    create_dir "$DIR_RUN_TIME_CONFIG"

    chmod +x scripts/*.sh

    # clear_file "$DIR_BUILD/CMakeCache.txt" # nie dało się inaczej, bo co chwila Cachował zmienne TEMPLATE___BUILD_LIBRARY i TEMPLATE___CTEST_ACTIVE,
    #                                        # nawet jeśli po zbudowaniu odtwarzałem je do poprzednich wartości

    # 1. Pętla getopts
    while getopts "ctl" opt; do
    case "$opt" in
        c)
            # just clean the env #       single makes exe -> ct cleans test, cl cleans lib
            {
                clear_dir "$DIR_BUILD"
            }
        ;;
        t)
            # Testing #
            {
                MARKER="TEST"
                [ "$( cat "$PATH_LAST_ARCH_MARKER" )" != "$MARKER" ] && clear_dir "$DIR_BUILD" && echo "$MARKER" > $PATH_LAST_ARCH_MARKER

                export FLAG_TESTING_ACTIVE="Yes"
            }
            break
        ;;
        l)
            # Lib generation #
            {
                MARKER="LIB"
                [ "$( cat "$PATH_LAST_ARCH_MARKER" )" != "$MARKER" ] && clear_dir "$DIR_BUILD" && echo "$MARKER" > $PATH_LAST_ARCH_MARKER

                export FLAG_BUILDING_LIBRARY="Yes"
            }
            break
        ;;
        \?)
        echo "Error: $0 getopts switch -$OPTARG" >&2
        exit 1
        ;;
    esac
    done

    # Usuń przetworzone opcje z listy argumentów #
    shift $((OPTIND -1))
    # echo "Pozostałe argumenty: $@"
}

#####################   START   #####################

env_prep "$@"

timer_start
{
    cd scripts || exit 1
    ./production.sh 2>&1 | tee "$LOG_container_compile"
    compilation_status=$?
}
timer_end

timer_print

exit $compilation_status
