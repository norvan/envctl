_api()
{
    local cur prev _ENV_LIST

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    ENVCTL_DIR=${ENVCTL_DIR:=~/.envctl/envs/}
    _ENV_LIST=$(ls $ENVCTL_DIR | grep ".env" | sed 's/.env$//')

    case ${COMP_CWORD} in
        1)
            COMPREPLY=($(compgen -W "ls status describe show edit set unset delete --version --help --upgrade" -- ${cur}))
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
                    COMPREPLY=($(compgen -W "${_ENV_LIST}" -- ${cur}))
                    ;;
                edit)
                    COMPREPLY=($(compgen -W "${_ENV_LIST}" -- ${cur}))
                    ;;
                set)
                    COMPREPLY=($(compgen -W "${_ENV_LIST}" -- ${cur}))
                    ;;
                unset)
                    COMPREPLY=($(compgen -W "${_ENV_LIST}" -- ${cur}))
                    ;;
                delete)
                    COMPREPLY=($(compgen -W "${_ENV_LIST}" -- ${cur}))
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
    ENVCTL_DIR=${ENVCTL_DIR:=~/.envctl/envs/}
    list() {
        ls $ENVCTL_DIR | grep ".env" | sed 's/.env$//'
    }
    show() {
        cat $ENVCTL_DIR"/"$1".env"
    }
    delete() {
        rm $ENVCTL_DIR"/"$1".env"
    }
    do_unset () {
        local env_to_unset NEW_ENV curr_env
        for env_to_unset in $@; do
            # TODO: handle case where env_to_unset is actually not set
            # TODO: handle case where the vars are in another env
            unset $(grep -v '^#' $ENVCTL_DIR"/"$env_to_set".env" | sed 's/=.*$//' | xargs)
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
        local env_to_set NEW_ENV
        for env_to_set in $@; do

            set -a; source $ENVCTL_DIR"/"$env_to_set".env"; set +a
            #export $(grep -v '^#' $ENVCTL_DIR"/"$env_to_set".env" | xargs)
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
                local curr_env position count
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
                "${EDITOR:-nano}" $ENVCTL_DIR"/"$2".env"
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
            delete)
                delete $2
                ;;
            version|--version|-v)
                local _VERSION
                _VERSION=23.05.18.001
                echo $_VERSION
                ;;
            --upgrade)
                curl https://raw.githubusercontent.com/norvan/envctl/main/envctl.sh > ~/.envctl/envctl.sh
                source ~/.envctl/envctl.sh
                ;;
            help|--help)
                ;;
            *)
                echo "Unknown commant: "$1" try one of: ls describe status show edit set unset"
                ;;
        esac
    }

    main $@
}

complete -F _api envctl
