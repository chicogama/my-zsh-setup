# Guia de Configuração do ZSH - SFTP e MobaXterm

## O que foi configurado?

### 1. **`.zshenv`** - Variáveis de Ambiente (CRÍTICO para SFTP)
   - Carregado em **TODAS** as sessões zsh, inclusive não-interativas
   - Contém: `JAVA_HOME`, `M2_HOME`, `PATH`, `LANG`
   - **Por que é importante**: SFTP usa shells não-interativas e não carrega `.zshrc`

### 2. **`.zprofile`** - Login Shell Configuration
   - Similar ao `.bash_profile`
   - Carrega `.zshrc` para sessões de login

### 3. **`.zshrc`** - Configurações Interativas
   - Otimizado para compatibilidade
   - Contém apenas plugins estáveis: `git`, `zsh-syntax-highlighting`, `zsh-autosuggestions`
   - Auto-update desabilitado (causa problemas em conexões remotas)
   - Verifica se é sessão interativa `[[ -z "$PS1" ]] && return`

### 4. **`.bashrc`** - Redirecionamento para ZSH
   - Carrega variáveis de `.zshenv` (compatibilidade)
   - Se for shell interativo, executa `exec zsh`
   - **SFTP não-interativo**: Não será afetado pelo `exec zsh`

## Teste de SFTP

Para verificar se SFTP funcionará corretamente:

```bash
# Teste 1: Verificar se variáveis de ambiente estão em .zshenv
echo "Variáveis de ambiente em .zshenv:"
cat ~/.zshenv

# Teste 2: Simular uma sessão SFTP não-interativa
echo "Teste de shell não-interativa:"
zsh -i -c 'echo "Java: $JAVA_HOME"; echo "Maven: $M2_HOME"'

# Teste 3: Executar com bash -c (simula SFTP)
echo "Teste de compatibilidade com SFTP:"
bash -c 'source ~/.zshenv && echo "Java: $JAVA_HOME"'
```

## Teste com MobaXterm

1. **Conectar via SSH pelo MobaXterm**
2. **Verificar shell atual**: `echo $SHELL`
3. **Se for `/bin/bash`**: Será automaticamente redirecionado para zsh na próxima conexão
4. **Verificar funcionalidades**:
   - Testar SFTP (arrastar/soltar arquivos)
   - Testar monitoring/logs

## Se SFTP continuar com problemas

### Opção 1: Desabilitar redirecionamento automático para SFTP
```bash
# Editar ~/.bashrc e comentar a linha:
# exec /usr/bin/zsh

# Depois, conecte manualmente com zsh quando precisar:
exec /usr/bin/zsh
```

### Opção 2: Configurar SFTP para usar bash explicitamente
No MobaXterm, editar configurações SSH para forçar bash.

### Opção 3: Criar shell wrapper para SFTP
Se necessário, criar um script que detecte SFTP e use bash apenas nesse caso.

## Variáveis importantes que migraram para .zshenv

```
JAVA_HOME="/opt/jdk-17.0.10"
M2_HOME="/opt/apache-maven-3.9.6"
LANG="pt_BR.UTF-8"
LC_ALL="pt_BR.UTF-8"
```

Todas estão agora em `.zshenv` garantindo disponibilidade em qualquer tipo de sessão.

## Solução de Problemas

### Problema: "Comando não encontrado" no SFTP
**Solução**: Verifique se `.zshenv` está presente e contém as variáveis corretas.

### Problema: Path incorreto
**Solução**: Execute `echo $PATH` em uma sessão zsh e compare com `.zshenv`.

### Problema: MobaXterm não reconhece comandos
**Solução**: Verifique se `~/.zshenv` tem permissões corretas:
```bash
chmod 644 ~/.zshenv ~/.zprofile ~/.zshrc
```

### Problema: oh-my-zsh não carrega
**Solução**: Verifique se oh-my-zsh está instalado:
```bash
[ -d ~/.oh-my-zsh ] && echo "oh-my-zsh instalado" || echo "oh-my-zsh NÃO instalado"
```

## Ativar ZSH explicitamente (sem reboot)

Se quiser começar a usar zsh imediatamente:
```bash
exec /usr/bin/zsh
```

Depois feche e abra uma nova conexão SSH/SFTP no MobaXterm.
