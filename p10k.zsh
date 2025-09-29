# Powerlevel10k preset approximating agnoster with Nord colors and TTY fallbacks

typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_COLOR_SCHEME='nord'

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time pyenv time)

# Nord-aligned colors
typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
typeset -g POWERLEVEL9K_VCS_BACKGROUND=6
# Remove background only for OS icon segment (keep others as-is)
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=

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

# Honor DOTFILES_UI_PROFILE exported from zshrc capability detection.
typeset -g DOTFILES_UI_PROFILE=${DOTFILES_UI_PROFILE:-nerdfont-truecolor}

if [[ ${DOTFILES_UI_PROFILE} == nerdfont-* ]]; then
  typeset -g POWERLEVEL9K_MODE='nerdfont-complete'

  # Curved powerline separators (/ family)
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\ue0b4'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\ue0b6'
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\ue0b5'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\ue0b7'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$'\ue0b6'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=$'\ue0b4'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$'\ue0b6'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=$'\ue0b4'

  ## Add one space after OS icon content
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='${P9K_CONTENT} '

  # Per-OS icon colors: Arch blue, Apple white
  # Note: colored icons override foreground for the glyph only.
  typeset -g POWERLEVEL9K_LINUX_ARCH_ICON='%F{blue}%f'
  typeset -g POWERLEVEL9K_APPLE_ICON='%F{white}%f'
else # ascii-* profile
  typeset -g POWERLEVEL9K_MODE='ascii'

  # Simplified ASCII separators with rounded vibe for raw TTYs
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=')'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='('
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='|'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='|'

  ## Match spacing expectations without glyphs
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='${P9K_CONTENT}'

  # Plain-text identifiers when Nerd Fonts are unavailable
  typeset -g POWERLEVEL9K_LINUX_ARCH_ICON='Arch'
  typeset -g POWERLEVEL9K_APPLE_ICON='macOS'
fi
