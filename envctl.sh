_api()
{
    local cur prev ENVCTL_REP ENVCTL_ENVS ENV_LIST

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    ENVCTL_REP=~/.envctl/envs/
    ENV_LIST=$(ls $ENVCTL_REP | grep ".env" | sed 's/.env$//')

    case ${COMP_CWORD} in
        1)
            COMPREPLY=($(compgen -W "ls status describe show edit set unset --version --help" -- ${cur}))
            ;;
        2)
            case ${prev} in
                ls)
                    COMPREPLY=($(compgen -W "some other args" -- ${cur}))
                    ;;
                status)
                    COMPREPLY=()
                    ;;
                describe)
                    COMPREPLY=()
                    ;;
                show)
                    COMPREPLY=($(compgen -W "${ENV_LIST}" -- ${cur}))
                    ;;
                edit)
                    COMPREPLY=($(compgen -W "${ENV_LIST}" -- ${cur}))
                    ;;
                set)
                    COMPREPLY=($(compgen -W "${ENV_LIST}" -- ${cur}))
                    ;;
                unset)
                    COMPREPLY=($(compgen -W "${ENV_LIST}" -- ${cur}))
                    ;;
            esac
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

envctl()
{
    local ENVCTL_REP
    ENVCTL_REP=~/.envctl/envs/
    list() {
        ls $ENVCTL_REP | grep ".env" | sed 's/.env$//'
    }
    show() {
        cat $ENVCTL_REP"/"$1".env"
    }
    do_unset () {
        for env_to_unset in $@; do
            # TODO: handle case where the vars are in another env
            unset $(grep -v '^#' $ENVCTL_REP"/"$env_to_set".env" | sed 's/=.*$//' | xargs)
            NEW_ENV=""
            for curr_env in $(echo "$ENVCTL_ENVS" | tr ':' '\n'); do
                if [ "$curr_env" != "$env_to_unset" ]; then
                    if [ -z "$NEW_ENV" ]; then
                        NEW_ENV=$curr_env
                    else
                        NEW_ENV=$NEW_ENV:$curr_env
                    fi
                fi
            done
            export ENVCTL_ENVS=$NEW_ENV
        done
    }
    do_set () {
        for env_to_set in $@; do

            set -a; source $ENVCTL_REP"/"$env_to_set".env"; set +a
            #export $(grep -v '^#' $ENVCTL_REP"/"$env_to_set".env" | xargs)
            # TODO: if it loads a var that's already been set by another, with a different value, show warning

            # Remove env_to_set from ENVCTL_ENVS
            NEW_ENV=""
            for curr_env in $(echo "$ENVCTL_ENVS" | tr ':' '\n'); do
                if [ "$curr_env" != "$env_to_set" ]; then
                    if [ -z "$NEW_ENV" ]; then
                        NEW_ENV=$curr_env
                    else
                        NEW_ENV=$NEW_ENV:$curr_env
                    fi
                fi
            done

            # Editing and exporting the ENVCTL_ENVS variable
            if [ -z "$ENVCTL_ENVS" ]; then
                export ENVCTL_ENVS=$env_to_set
            else
                export ENVCTL_ENVS=$env_to_set:$NEW_ENV
            fi

        done
    }
    main() {
        [ -z "$1" ] && list || case $1 in
            ls)
                echo "Available environments:"
                for i in $(list); do

                    position=" "
                    count=1
                    for curr_env in $(echo "$ENVCTL_ENVS" | tr ':' '\n'); do
                        if [ "$curr_env" = "$i" ]; then
                            position="$count"
                            break
                        else
                            count=`expr $count + 1`
                        fi
                    done

                    if [ "$position" = " " ]; then
                        echo "     "$i
                    else
                        echo "($position)  "$i
                    fi
                done
                ;;
            status)
                echo $ENVCTL_ENVS
                ;;
            describe)
                echo "TODO, a way to see which envs come from where"
                ;;
            edit)
                "${EDITOR:-nano}" $ENVCTL_REP"/"$2".env"
                ;;
            show)
                show $2
                ;;
            set)
                shift 1
                do_set $@
                ;;
            unset)
                shift 1
                do_unset $@
                ;;
            version|--version|-v)
                echo 0.1.0
                ;;
            help|--help)
                echo 0.1.0
                ;;
            *)
                echo "Unknown commant: "$1" try one of: ls describe status show edit set unset"
                ;;
        esac
    }

    main $@
}

complete -F _api envctl