# my-zsh-setup

Automação de instalação e configuração do ZSH com preservação de personalizações (plugins, temas).

## 🚀 Instalação Rápida

```bash
cd ~/my-zsh-setup
./install.sh
```

## 📋 Opções Disponíveis

### Simulação (sem alterações)
```bash
./install.sh --dry-run -v
```

### Instalação com Backup (recomendado)
```bash
./install.sh --backup -v
```

### Instalação sem Backup (CUIDADO)
```bash
./install.sh --no-backup
```

### Instalação e troca do shell padrão para zsh
```bash
./install.sh --change-shell
```

### Ajuda
```bash
./install.sh --help
```

## 🧰 Dependências

O script verifica e tenta instalar automaticamente as dependências abaixo, detectando o
gerenciador de pacotes disponível (`apt`, `dnf`, `yum`, `pacman`, `zypper` no Linux, ou
`brew` no macOS):

| Dependência | Finalidade | Obrigatória? |
|-------------|-----------|--------------|
| `git`   | Instalar Oh My Zsh, plugins e tema Spaceship | Sim |
| `curl`  | Baixar o instalador do Oh My Zsh e a fonte Nerd Font | Sim |
| `zsh`   | Shell utilizado pela configuração | Sim |
| `unzip` | Descompactar a fonte Nerd Font (Linux) | Apenas Linux |
| `fc-cache` | Atualizar cache de fontes (Linux, se disponível) | Opcional |

Se nenhum gerenciador de pacotes suportado for encontrado, o script exibe uma mensagem
clara pedindo para instalar a dependência manualmente antes de continuar.

## 📦 O que é Instalado?

| Arquivo | Propósito | Tipo |
|---------|----------|------|
| `.zshenv` | Variáveis de ambiente (todas as sessões) | Crítico para SFTP |
| `.zshrc` | Configurações interativas do shell | Personalizado |
| `.zprofile` | Configuração de login shell | Padrão |
| `.bashrc` | Compatibilidade com Bash | Padrão |
| `.bash_profile` | Perfil Bash | Padrão |

## ✨ Características

- ✅ **Automação** - Script bash de instalação automática, idempotente e robusto (`set -euo pipefail`)
- ✅ **Backup** - Cria backups com timestamp antes de alterações
- ✅ **Merge** - Detecta e preserva plugins e temas existentes
- ✅ **SFTP** - Otimizado para sessões não-interativas (SFTP/MobaXterm)
- ✅ **Dependências** - Detecta e instala automaticamente git, curl, zsh e unzip
- ✅ **Oh My Zsh** - Instala o Oh My Zsh de forma não-interativa quando ausente
- ✅ **Plugins** - Instala `zsh-syntax-highlighting` e `zsh-autosuggestions` via git clone
- ✅ **Nerd Font** - Instala a fonte Meslo Nerd Font (Linux e macOS)
- ✅ **Tema Spaceship** - Clona e configura o tema `spaceship-prompt`
- ✅ **Idempotência** - Pode ser executado múltiplas vezes sem duplicar instalações
- ✅ **Verificação** - Testes automáticos de variáveis de ambiente e componentes instalados
- ✅ **Rollback** - Instruções para reverter em caso de necessidade

## 🔧 Variáveis de Ambiente

As seguintes variáveis são configuradas em `.zshenv`:

```bash
JAVA_HOME="/opt/jdk-17.0.10"
M2_HOME="/opt/apache-maven-3.9.6"
EDITOR="vim"
LANG="pt_BR.UTF-8"  # (comentado)
```

## 🧪 Testes de Verificação

Após a instalação, o script executa automaticamente:

1. **Variáveis de Ambiente**
   ```bash
   echo $JAVA_HOME
   echo $M2_HOME
   ```

2. **Teste SFTP**
   ```bash
   bash -c 'source ~/.zshenv && echo $JAVA_HOME'
   ```

3. **Permissões de Arquivo**
   ```bash
   ls -lh ~/.zsh*
   ```

## 🔙 Rollback

Se precisar reverter para a configuração anterior:

```bash
# Listar backups disponíveis
ls -la ~/.zsh_backups

# Restaurar um backup específico
cp ~/.zsh_backups/.zshrc.20260417_101847 ~/.zshrc
```

Todos os backups são salvos em `~/.zsh_backups/`

## 📖 Documentação Adicional

- [ZSH_CONFIGURATION_GUIDE.md](ZSH_CONFIGURATION_GUIDE.md) - Guia completo de configuração
- [.github/instructions/zsh-instructions.instructions.md](.github/instructions/zsh-instructions.instructions.md) - Diretrizes do projeto

## 🐛 Troubleshooting

### "Comando não encontrado" em SFTP
Verifique se `.zshenv` foi instalado corretamente:
```bash
test -f ~/.zshenv && echo "OK" || echo "ERRO"
```

### Variáveis de ambiente não carregam
Certifique-se de que `.zshenv` tem permissões de leitura:
```bash
chmod 644 ~/.zshenv
```

### oh-my-zsh não carrega
Verifique se oh-my-zsh está instalado:
```bash
[ -d ~/.oh-my-zsh ] && echo "Instalado" || echo "Não instalado"
```

## 📝 Plugins Padrão

O projeto pré-configura os seguintes plugins compatíveis:
- `git` - Integração com Git
- `zsh-syntax-highlighting` - Destaque de sintaxe
- `zsh-autosuggestions` - Sugestões automáticas

## 🎨 Tema Padrão

Tema: **spaceship**

O script clona automaticamente [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt)
em `$ZSH_CUSTOM/themes/spaceship-prompt` e cria o symlink `spaceship.zsh-theme` necessário
para o Oh My Zsh reconhecer o tema.

Para mudar de tema, edite `~/.zshrc`:
```bash
ZSH_THEME="seu-tema-aqui"
```

## 🔤 Fonte Recomendada (Nerd Font)

O tema Spaceship e diversos plugins usam ícones especiais que exigem uma **Nerd Font**.
O script instala automaticamente a fonte **Meslo Nerd Font**:

- **Linux**: baixa o zip oficial do [nerd-fonts](https://github.com/ryanoasis/nerd-fonts),
  instala em `~/.local/share/fonts` e atualiza o cache com `fc-cache` (se disponível).
- **macOS**: instala via Homebrew Cask (`brew install --cask font-meslo-lg-nerd-font`),
  quando o Homebrew estiver disponível.

Após a instalação, **configure o terminal** (iTerm2, Windows Terminal, GNOME Terminal, etc.)
para usar a fonte **"MesloLGS NF"**, caso contrário os ícones do prompt aparecerão como
caracteres inválidos (□).

## 📄 Licença

Este projeto é de uso pessoal.
