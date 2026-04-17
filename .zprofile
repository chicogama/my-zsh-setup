# .zprofile - Executado para shells de login
# Similar ao .bash_profile

# Se .zshrc existir, executá-lo
if [[ -f "$HOME/.zshrc" ]]; then
    . "$HOME/.zshrc"
fi
