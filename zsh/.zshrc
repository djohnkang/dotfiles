# ============================================================
# PATH
# ============================================================
export PATH="$HOME/.local/bin:$PATH"

# ============================================================
# Homebrew
# ============================================================
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ============================================================
# pyenv
# ============================================================
if command -v pyenv &>/dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# ============================================================
# nvm
# ============================================================
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ============================================================
# direnv
# ============================================================
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ============================================================
# Starship 프롬프트
# ============================================================
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ============================================================
# History
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history hist_ignore_dups hist_ignore_space

# ============================================================
# Completions
# ============================================================
autoload -Uz compinit && compinit

# ============================================================
# Aliases
# ============================================================
alias ccd='claude --dangerously-skip-permissions'

# ============================================================
# 머신별 로컬 설정 (gitignore 대상)
# ============================================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
