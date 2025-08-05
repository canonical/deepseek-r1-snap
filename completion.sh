# bash completion for deepseek-r1                          -*- shell-script -*-

_deepseek_r1_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # Subcommands
    opts="chat status info list load use get set unset help system"

    if [[ "$cur" == -* ]]; then
        _deepseek_r1_complete_options "$cur"
        return 0
    fi

    # Complete the first argument with subcommands
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
        return 0
    fi
}

_deepseek_r1_complete_options() {
    local curr=$1
    local options="-h --help"
    COMPREPLY=($(compgen -W "$options" -- "$cur"))
}

complete -F _deepseek_r1_completions deepseek-r1

# ex: ts=4 sw=4 et filetype=sh
