# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: zoxide
# @brief: Initialize `zoxide` shell integration.
# @repository: https://github.com/johnstonskj/zsh-zoxide-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# ### Public Variables
#
# * `_ZO_DATA_DIR`; set to `${XDG_DATA_HOME}/zoxide`.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

zoxide_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save zoxide _ZO_DATA_DIR
    export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"
    if [[ ! -d "${_ZO_DATA_DIR}" ]]; then
        mkdir -p "${_ZO_DATA_DIR}"
    fi

    @zplugins_define_alias zoxide cd 'z'
}

# @internal
zoxide_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore zoxide _ZO_DATA_DIR
}
