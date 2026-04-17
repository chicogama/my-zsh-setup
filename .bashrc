# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Compatibilidade com configurações do zsh - carrega variáveis de ambiente
if [ -f "$HOME/.zshenv" ]; then
    . "$HOME/.zshenv"
fi

# User specific aliases and functions
# Se este é um shell interativo e zsh está disponível, iniciar zsh
if [[ $- == *i* ]] && [ -x /usr/bin/zsh ]; then
    exec /usr/bin/zsh
fi

