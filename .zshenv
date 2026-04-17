# .zshenv - Carregado em TODAS as sessões zsh (inclusive não-interativas como SFTP)
# Deve conter apenas variáveis de ambiente, sem comandos complexos

# Java
export JAVA_HOME="/opt/jdk-17.0.10"

# Maven
export M2_HOME="/opt/apache-maven-3.9.6"

# PATH - Consolidado
export PATH="$JAVA_HOME/bin:$M2_HOME/bin:$HOME/.local/bin:$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Idioma e locale
#export LANG="pt_BR.UTF-8"
#export LC_ALL="pt_BR.UTF-8"

# Editor padrão
export EDITOR="vim"
