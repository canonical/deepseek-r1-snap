# bash completion for deepseek-r1                          -*- shell-script -*-
# shellcheck disable=SC2016,SC2119,SC2155,SC2206,SC2207,SC2254,SC2034
#
# Shellcheck ignore list:
#  - SC2016: Expressions don't expand in single quotes, use double quotes for that.
#  - SC2119: Use foo "$@" if function's $1 should mean script's $1.
#  - SC2155: Declare and assign separately to avoid masking return values.
#  - SC2206: Quote to prevent word splitting, or split robustly with mapfile or read -a.
#  - SC2207: Prefer mapfile or read -a to split command output (or quote to avoid splitting).
#  - SC2254: Quote expansions in case patterns to match literally rather than as a glob.
#  - SC2034:  Expression appears unused. Verify use (or export if used externally).

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

    # If the first subcommand is "use" or "info", provide stack options
    if [[ ("${COMP_WORDS[1]}" == "use" || "${COMP_WORDS[1]}" == "info") && ${COMP_CWORD} -eq 2 ]]; then
        # list of stacks from https://github.com/canonical/deepseek-r1-snap/tree/main/stacks
        local stacks="ampere-altra ampere-one cpu-avx512 cpu-legacy cpu-tiny cpu cuda intel-gpu intel-npu"
        COMPREPLY=($(compgen -W "${stacks}" -- "${cur}"))
        return 0
    fi

    # If subcommand is "get" or "set", provide config options
    if [[ ("${COMP_WORDS[1]}" == "get" || "${COMP_WORDS[1]}" == "set") && ${COMP_CWORD} -eq 2 ]]; then
        local configs="engine http model stack"
        COMPREPLY=($(compgen -W "${configs}" -- "${cur}"))
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
