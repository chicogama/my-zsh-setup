# .zshrc - Configurações interativas do zsh
# Verificar se é uma sessão interativa
[[ -z "$PS1" ]] && return

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="spaceship"

# Desabilitar auto-update para compatibilidade
zstyle ':omz:update' mode disabled

# Plugins otimizados para compatibilidade com SFTP e MobaXterm
plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
)

# Source oh-my-zsh se existir
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
	source $ZSH/oh-my-zsh.sh
fi

# Configurações de histórico
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# Opções de histórico
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Completion configuration
autoload -Uz compinit
compinit

# Aliases
alias l='ls -lahrt'
