# Powerlevel10k preset approximating agnoster with Nord colors

typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
typeset -g POWERLEVEL9K_COLOR_SCHEME='nord'

# Prompt layout
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time pyenv time)

# Prompt separators similar to agnoster
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\ue0b0'
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\ue0b2'
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\ue0b1'
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\ue0b3'

# Nord-aligned colors
typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
typeset -g POWERLEVEL9K_VCS_BACKGROUND=6
# Remove background only for OS icon segment (keep others as-is)
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=
## Add one space after OS icon content
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='${P9K_CONTENT} '

# Per-OS icon colors: Arch blue, Apple white
# Note: colored icons override foreground for the glyph only.
typeset -g POWERLEVEL9K_LINUX_ARCH_ICON='%F{blue}%f'
typeset -g POWERLEVEL9K_APPLE_ICON='%F{white}%f'

# Shorten directory path aggressively inside git repos
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
typeset -g POWERLEVEL9K_SHORTEN_DIR_DELIMITER='/'
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_unique'

# VCS indicators
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=1
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=3

# Status segment
typeset -g POWERLEVEL9K_STATUS_VERBOSE=false

# Execution time displayed for commands taking >1s
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1
