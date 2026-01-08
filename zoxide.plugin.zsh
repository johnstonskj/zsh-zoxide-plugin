# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: zoxide
# Repository: https://github.com/johnstonskj/zsh-zoxide-plugin
#
# Description:
#
#   Zsh plugin to initialize zoxide shell integration.
#
# Public variables:
#
# * `ZOXIDE`; plugin-defined global associative array with the following keys:
#   * `_ALIASES`; a list of all aliases defined by the plugin.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
# * `ZOXIDE_EXAMPLE`; if set it does something magical.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA ZOXIDE
ZOXIDE[_PLUGIN_DIR]="${0:h}"
ZOXIDE[_ALIASES]=""
ZOXIDE[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
ZOXIDE[_OLD_DATA_DIR]="${_ZO_DATA_DIR}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `ZOXIDE[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.zoxide_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${ZOXIDE[_FUNCTIONS]}" ]]; then
        ZOXIDE[_FUNCTIONS]="${fn_name}"
    elif [[ ",${ZOXIDE[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        ZOXIDE[_FUNCTIONS]="${ZOXIDE[_FUNCTIONS]},${fn_name}"
    fi
}
.zoxide_remember_fn .zoxide_remember_fn

.zoxide_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${ZOXIDE[_ALIASES]}" ]]; then
        ZOXIDE[_ALIASES]="${alias_name}"
    elif [[ ",${ZOXIDE[_ALIASES]}," != *",${alias_name},"* ]]; then
        ZOXIDE[_ALIASES]="${ZOXIDE[_ALIASES]},${alias_name}"
    fi
}
.zoxide_remember_fn .zoxide_remember_alias

#
# This function does the initialization of variables in the global variable
# `ZOXIDE`. It also adds to `path` and `fpath` as necessary.
#
zoxide_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

     # Export environment variables.
    export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"
    if [[ ! -d "${_ZO_DATA_DIR}" ]]; then
        mkdir -p "${_ZO_DATA_DIR}"
    fi

    # Define any aliases here, or in their own section below.
    .zoxide_define_alias cd 'z'
}
.zoxide_remember_fn zoxide_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
zoxide_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${ZOXIDE[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
    
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${ZOXIDE[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done
    
    # Reset global environment variables .
    export _ZO_DATA_DIR="${ZOXIDE[_OLD_DATA_DIR]}"

    # Remove the global data variable (after above!).
    unset ZOXIDE

    # Remove this function last.
    unfunction zoxide_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

zoxide_plugin_init

eval "$(zoxide init zsh)"

true
