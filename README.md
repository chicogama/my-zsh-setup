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

### Ajuda
```bash
./install.sh --help
```

## 📦 O que é Instalado?

| Arquivo | Propósito | Tipo |
|---------|----------|------|
| `.zshenv` | Variáveis de ambiente (todas as sessões) | Crítico para SFTP |
| `.zshrc` | Configurações interativas do shell | Personalizado |
| `.zprofile` | Configuração de login shell | Padrão |
| `.bashrc` | Compatibilidade com Bash | Padrão |
| `.bash_profile` | Perfil Bash | Padrão |

## ✨ Características

- ✅ **Automação** - Script bash de instalação automática
- ✅ **Backup** - Cria backups com timestamp antes de alterações
- ✅ **Merge** - Detecta e preserva plugins e temas existentes
- ✅ **SFTP** - Otimizado para sessões não-interativas (SFTP/MobaXterm)
- ✅ **Verificação** - Testes automáticos de variáveis de ambiente
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

Para mudar de tema, edite `~/.zshrc`:
```bash
ZSH_THEME="seu-tema-aqui"
```

## 📄 Licença

Este projeto é de uso pessoal.
