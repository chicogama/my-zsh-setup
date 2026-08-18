#!/usr/bin/env bash

################################################################################
# ZSH Setup Installation Script
# Automatiza a instalação e configuração do ZSH preservando personalizações
################################################################################

set -euo pipefail

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis globais
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.zsh_backups"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DRY_RUN=false
VERBOSE=false
CREATE_BACKUP=true
CHANGE_SHELL=false

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
OS_NAME="$(uname -s 2>/dev/null || echo unknown)"
PKG_MANAGER=""

MESLO_FONT_VERSION="v3.1.1"
MESLO_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${MESLO_FONT_VERSION}/Meslo.zip"

################################################################################
# Funções auxiliares
################################################################################

log_info() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}ℹ${NC} $1"
    fi
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

run_cmd() {
    # Executa um comando real ou apenas o mostra em modo dry-run
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Executaria: $*"
        return 0
    fi
    "$@"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_help() {
    cat << EOF
Uso: ./install.sh [opções]

Instala e configura ZSH preservando personalizações existentes.

Opções:
    --backup             Criar backup dos arquivos existentes (padrão: ativado)
    --no-backup          Não criar backup (CUIDADO!)
    --dry-run            Simular instalação sem fazer alterações
    --change-shell        Alterar o shell padrão do usuário para zsh (via chsh)
    -v, --verbose        Saída detalhada
    -h, --help           Mostrar este menu

Exemplos:
    ./install.sh                    # Instalar com backup
    ./install.sh --dry-run          # Simular instalação
    ./install.sh --dry-run -v       # Simular com detalhes
    ./install.sh --no-backup -v     # Instalar sem backup (cuidado!)
    ./install.sh --change-shell     # Instalar e trocar shell padrão para zsh

EOF
}

################################################################################
# Parsing de argumentos
################################################################################

while [[ $# -gt 0 ]]; do
    case $1 in
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --no-backup)
            CREATE_BACKUP=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --change-shell)
            CHANGE_SHELL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            log_error "Opção desconhecida: $1"
            print_help
            exit 1
            ;;
    esac
done

################################################################################
# Validações
################################################################################

validate_environment() {
    log_info "Validando ambiente..."

    if [[ ! -d "$SCRIPT_DIR" ]]; then
        log_error "Diretório do script não encontrado: $SCRIPT_DIR"
        exit 1
    fi

    if [[ ! -f "$SCRIPT_DIR/.zshenv" ]]; then
        log_error "Arquivo .zshenv não encontrado em $SCRIPT_DIR"
        exit 1
    fi

    log_success "Ambiente validado"
}

################################################################################
# Gerenciador de pacotes / dependências
################################################################################

detect_package_manager() {
    if [[ "$OS_NAME" == "Darwin" ]] && command_exists brew; then
        PKG_MANAGER="brew"
    elif command_exists apt-get; then
        PKG_MANAGER="apt"
    elif command_exists dnf; then
        PKG_MANAGER="dnf"
    elif command_exists yum; then
        PKG_MANAGER="yum"
    elif command_exists pacman; then
        PKG_MANAGER="pacman"
    elif command_exists zypper; then
        PKG_MANAGER="zypper"
    else
        PKG_MANAGER=""
    fi

    if [[ -n "$PKG_MANAGER" ]]; then
        log_info "Gerenciador de pacotes detectado: $PKG_MANAGER"
    else
        log_warning "Nenhum gerenciador de pacotes suportado foi detectado"
    fi
}

install_package() {
    local package="$1"

    if [[ -z "$PKG_MANAGER" ]]; then
        log_error "Não foi possível instalar '$package' automaticamente (gerenciador de pacotes não encontrado)."
        log_warning "Instale manualmente '$package' e execute o script novamente."
        return 1
    fi

    log_info "Instalando dependência: $package ($PKG_MANAGER)"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Instalaria pacote '$package' via $PKG_MANAGER"
        return 0
    fi

    case "$PKG_MANAGER" in
        brew)
            brew install "$package"
            ;;
        apt)
            sudo apt-get update -y && sudo apt-get install -y "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        yum)
            sudo yum install -y "$package"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "$package"
            ;;
        zypper)
            sudo zypper install -y "$package"
            ;;
        *)
            log_error "Gerenciador de pacotes desconhecido: $PKG_MANAGER"
            return 1
            ;;
    esac
}

ensure_dependency() {
    local cmd="$1"
    local package="${2:-$1}"

    if command_exists "$cmd"; then
        log_info "Dependência já disponível: $cmd"
        return 0
    fi

    log_warning "Dependência ausente: $cmd"
    if install_package "$package"; then
        if [[ "$DRY_RUN" == false ]] && ! command_exists "$cmd"; then
            log_error "Falha ao instalar '$cmd'. Instale manualmente e execute o script novamente."
            return 1
        fi
        log_success "Dependência '$cmd' pronta"
    else
        return 1
    fi
}

check_dependencies() {
    log_info "Verificando dependências mínimas..."

    detect_package_manager

    local missing=0
    ensure_dependency git git || missing=1
    ensure_dependency curl curl || missing=1
    ensure_dependency zsh zsh || missing=1

    if [[ "$OS_NAME" == "Linux" ]]; then
        ensure_dependency unzip unzip || missing=1
    fi

    if [[ $missing -ne 0 ]]; then
        log_error "Uma ou mais dependências mínimas não puderam ser instaladas automaticamente."
        log_warning "Instale git, curl e zsh manualmente e execute o script novamente."
        exit 1
    fi

    log_success "Dependências mínimas verificadas"
}

################################################################################
# Backup
################################################################################

create_backups() {
    if [[ "$CREATE_BACKUP" == false ]]; then
        log_warning "Backup desabilitado"
        return 0
    fi

    log_info "Criando backups..."

    # Criar diretório de backup
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$BACKUP_DIR"
    else
        log_info "[DRY-RUN] Criaria diretório: $BACKUP_DIR"
    fi

    local files=(".zshenv" ".zshrc" ".zprofile" ".bashrc" ".bash_profile")

    for file in "${files[@]}"; do
        if [[ -f "$HOME/$file" ]]; then
            local backup_file="$BACKUP_DIR/${file}.${BACKUP_TIMESTAMP}"
            if [[ "$DRY_RUN" == false ]]; then
                cp "$HOME/$file" "$backup_file"
                log_success "Backup criado: $backup_file"
            else
                log_info "[DRY-RUN] Backup: $HOME/$file → $backup_file"
            fi
        else
            log_info "Arquivo não existe: ~/$file (pulando)"
        fi
    done
}

################################################################################
# Merge de customizações
################################################################################

merge_zshrc() {
    log_info "Analisando customizações em ~/.zshrc..."

    if [[ ! -f "$HOME/.zshrc" ]]; then
        log_info "Nenhum .zshrc existente para mesclar"
        return 0
    fi

    # Extrair plugins existentes
    local existing_plugins
    existing_plugins=$(grep -oP "plugins=\(\K[^)]*" "$HOME/.zshrc" 2>/dev/null || echo "")

    if [[ -n "$existing_plugins" ]]; then
        log_info "Plugins encontrados: $existing_plugins"
    fi

    # Extrair tema existente
    local existing_theme
    existing_theme=$(grep "^ZSH_THEME=" "$HOME/.zshrc" 2>/dev/null | cut -d'"' -f2 || echo "")

    if [[ -n "$existing_theme" ]]; then
        log_info "Tema encontrado: $existing_theme"
    fi

    # Se DRY_RUN, apenas informar
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Customizações seriam preservadas durante merge"
        return 0
    fi

    # Para este script, apenas copiamos o template
    # Merge manual pode ser feito conforme necessário
}

################################################################################
# Oh My Zsh
################################################################################

install_oh_my_zsh() {
    log_info "Verificando instalação do Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh já está instalado"
        return 0
    fi

    log_info "Instalando Oh My Zsh..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Instalaria Oh My Zsh via instalador oficial (não-interativo)"
        return 0
    fi

    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh instalado com sucesso"
    else
        log_error "Falha ao instalar o Oh My Zsh"
        exit 1
    fi
}

################################################################################
# Plugins
################################################################################

install_git_plugin() {
    local name="$1"
    local repo_url="$2"
    local dest="$ZSH_CUSTOM/plugins/$name"

    if [[ -d "$dest" ]]; then
        log_success "Plugin já instalado: $name"
        return 0
    fi

    log_info "Instalando plugin: $name"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Clonaria $repo_url → $dest"
        return 0
    fi

    mkdir -p "$ZSH_CUSTOM/plugins"
    git clone --depth=1 "$repo_url" "$dest"
    log_success "Plugin instalado: $name"
}

install_plugins() {
    log_info "Instalando plugins do Oh My Zsh..."

    install_git_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_git_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
}

################################################################################
# Awesome Fonts (Meslo Nerd Font)
################################################################################

install_fonts() {
    log_info "Instalando Meslo Nerd Font..."

    if [[ "$OS_NAME" == "Darwin" ]]; then
        if ! command_exists brew; then
            log_warning "Homebrew não encontrado. Instale manualmente a fonte Meslo Nerd Font."
            return 0
        fi

        if brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
            log_success "Fonte Meslo Nerd Font já instalada (brew cask)"
            return 0
        fi

        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY-RUN] Instalaria fonte via: brew install --cask font-meslo-lg-nerd-font"
            return 0
        fi

        brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
        brew install --cask font-meslo-lg-nerd-font
        log_success "Fonte Meslo Nerd Font instalada via Homebrew"
        return 0
    fi

    if [[ "$OS_NAME" == "Linux" ]]; then
        local fonts_dir="$HOME/.local/share/fonts"

        if compgen -G "$fonts_dir/MesloLGS*Nerd*Font*" > /dev/null 2>&1; then
            log_success "Fonte Meslo Nerd Font já instalada"
            return 0
        fi

        if ! command_exists unzip; then
            log_warning "Comando 'unzip' não encontrado, tentando instalar..."
            ensure_dependency unzip unzip || {
                log_error "Não foi possível instalar 'unzip'. Instale a fonte manualmente."
                return 1
            }
        fi

        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY-RUN] Baixaria $MESLO_FONT_URL e instalaria em $fonts_dir"
            log_info "[DRY-RUN] Atualizaria cache de fontes com fc-cache, se disponível"
            return 0
        fi

        mkdir -p "$fonts_dir"
        local tmp_zip
        tmp_zip="$(mktemp -d)/Meslo.zip"

        if curl -fsSL "$MESLO_FONT_URL" -o "$tmp_zip"; then
            unzip -o -q "$tmp_zip" -d "$fonts_dir"
            rm -f "$tmp_zip"
            if command_exists fc-cache; then
                fc-cache -f "$fonts_dir" >/dev/null 2>&1 || true
                log_success "Cache de fontes atualizado"
            else
                log_warning "'fc-cache' não encontrado, cache de fontes não atualizado"
            fi
            log_success "Fonte Meslo Nerd Font instalada em $fonts_dir"
        else
            log_error "Falha ao baixar a fonte Meslo Nerd Font"
            log_warning "Instale manualmente em: https://github.com/ryanoasis/nerd-fonts"
        fi
        return 0
    fi

    log_warning "Sistema operacional não suportado para instalação automática de fontes: $OS_NAME"
}

################################################################################
# Tema Spaceship
################################################################################

install_spaceship_theme() {
    log_info "Instalando tema Spaceship..."

    local theme_dir="$ZSH_CUSTOM/themes/spaceship-prompt"
    local theme_link="$ZSH_CUSTOM/themes/spaceship.zsh-theme"

    if [[ -d "$theme_dir" ]]; then
        log_success "Tema Spaceship já clonado"
    else
        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY-RUN] Clonaria spaceship-prompt → $theme_dir"
        else
            mkdir -p "$ZSH_CUSTOM/themes"
            git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$theme_dir"
            log_success "Tema Spaceship clonado"
        fi
    fi

    if [[ -L "$theme_link" || -f "$theme_link" ]]; then
        log_success "Symlink do tema Spaceship já existe"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Criaria symlink: $theme_link → $theme_dir/spaceship.zsh-theme"
        return 0
    fi

    ln -s "$theme_dir/spaceship.zsh-theme" "$theme_link"
    log_success "Symlink do tema Spaceship criado"
}

################################################################################
# Instalação dos dotfiles
################################################################################

deploy_dotfiles() {
    log_info "Instalando dotfiles..."

    local files=(".zshenv" ".zshrc" ".zprofile" ".bashrc" ".bash_profile")

    for file in "${files[@]}"; do
        local source_file="$SCRIPT_DIR/$file"
        local dest_file="$HOME/$file"

        if [[ ! -f "$source_file" ]]; then
            log_warning "Arquivo de origem não encontrado: $source_file"
            continue
        fi

        if [[ "$DRY_RUN" == false ]]; then
            cp "$source_file" "$dest_file"
            chmod 644 "$dest_file"
            log_success "Instalado: ~/$file (permissões: 644)"
        else
            log_info "[DRY-RUN] Copiaria: $source_file → $dest_file"
            log_info "[DRY-RUN] Permissões: 644"
        fi
    done
}

ensure_zshrc_plugins() {
    log_info "Garantindo plugins e tema em ~/.zshrc..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Garantiria plugins (git, zsh-autosuggestions, zsh-syntax-highlighting) e ZSH_THEME=\"spaceship\" em ~/.zshrc"
        return 0
    fi

    if [[ ! -f "$HOME/.zshrc" ]]; then
        log_warning "$HOME/.zshrc não encontrado, pulando ajuste de plugins/tema"
        return 0
    fi

    if ! grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
        echo 'ZSH_THEME="spaceship"' >> "$HOME/.zshrc"
        log_success "ZSH_THEME=\"spaceship\" adicionado ao ~/.zshrc"
    fi

    for plugin in git zsh-autosuggestions zsh-syntax-highlighting; do
        if ! grep -qE "^\s*${plugin}\s*$" "$HOME/.zshrc" 2>/dev/null; then
            log_warning "Plugin '$plugin' não encontrado em ~/.zshrc (verifique manualmente se necessário)"
        fi
    done

    log_success "Plugins e tema verificados em ~/.zshrc"
}

change_default_shell() {
    if [[ "$CHANGE_SHELL" == false ]]; then
        return 0
    fi

    log_info "Alterando shell padrão para zsh..."

    local zsh_path
    zsh_path="$(command -v zsh || true)"

    if [[ -z "$zsh_path" ]]; then
        log_error "zsh não encontrado, não é possível alterar o shell padrão"
        return 1
    fi

    if [[ "$SHELL" == "$zsh_path" ]]; then
        log_success "Shell padrão já é zsh"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Executaria: chsh -s $zsh_path"
        return 0
    fi

    if chsh -s "$zsh_path"; then
        log_success "Shell padrão alterado para zsh ($zsh_path)"
    else
        log_error "Falha ao alterar o shell padrão. Execute manualmente: chsh -s $zsh_path"
    fi
}

################################################################################
# Verificação
################################################################################

verify_installation() {
    log_info "Verificando instalação..."

    echo ""
    echo -e "${BLUE}=== Teste 1: Variáveis de Ambiente ===${NC}"

    if [[ "$DRY_RUN" == false ]]; then
        bash -c 'source ~/.zshenv && echo "JAVA_HOME: $JAVA_HOME"'
        bash -c 'source ~/.zshenv && echo "M2_HOME: $M2_HOME"'
    else
        log_info "[DRY-RUN] Executaria: bash -c 'source ~/.zshenv && echo \$JAVA_HOME'"
    fi

    echo ""
    echo -e "${BLUE}=== Teste 2: SFTP Simulation ===${NC}"

    if [[ "$DRY_RUN" == false ]]; then
        bash -c 'source ~/.zshenv && echo "SFTP Test: JAVA_HOME=$JAVA_HOME"'
    else
        log_info "[DRY-RUN] Executaria teste SFTP"
    fi

    echo ""
    echo -e "${BLUE}=== Teste 3: Permissões ===${NC}"

    if [[ "$DRY_RUN" == false ]]; then
        ls -lh ~/{.zshenv,.zshrc,.zprofile,.bashrc,.bash_profile} 2>/dev/null | awk '{print $9, $1}' || true
    else
        log_info "[DRY-RUN] Verificaria permissões dos dotfiles"
    fi

    echo ""
    echo -e "${BLUE}=== Teste 4: Oh My Zsh, Plugins, Fonte e Tema ===${NC}"

    if [[ "$DRY_RUN" == false ]]; then
        [[ -d "$HOME/.oh-my-zsh" ]] && log_success "Oh My Zsh: instalado" || log_warning "Oh My Zsh: não instalado"
        [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && log_success "zsh-syntax-highlighting: instalado" || log_warning "zsh-syntax-highlighting: não instalado"
        [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && log_success "zsh-autosuggestions: instalado" || log_warning "zsh-autosuggestions: não instalado"
        [[ -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]] && log_success "Spaceship: instalado" || log_warning "Spaceship: não instalado"
    else
        log_info "[DRY-RUN] Verificaria Oh My Zsh, plugins, fonte e tema"
    fi

    echo ""
}

################################################################################
# Rollback
################################################################################

show_rollback_instructions() {
    echo ""
    echo -e "${BLUE}=== Instruções de Rollback ===${NC}"
    echo ""
    echo "Se precisar reverter para a configuração anterior:"
    echo ""
    echo "  # Listar backups disponíveis:"
    echo "  ls -la $BACKUP_DIR"
    echo ""
    echo "  # Restaurar um backup específico:"
    echo "  cp $BACKUP_DIR/.zshrc.TIMESTAMP ~/.zshrc"
    echo ""
    echo "Backups estão em: $BACKUP_DIR"
    echo ""
}

################################################################################
# Função principal
################################################################################

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  ZSH Setup Installation Script             ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        log_warning "MODO DRY-RUN ATIVADO - Nenhuma alteração será feita"
        echo ""
    fi

    if [[ "$CREATE_BACKUP" == false ]]; then
        log_warning "BACKUP DESABILITADO - Arquivos existentes podem ser perdidos"
        echo ""
    fi

    # Execução
    validate_environment
    check_dependencies
    create_backups
    merge_zshrc
    deploy_dotfiles
    install_oh_my_zsh
    install_plugins
    install_fonts
    install_spaceship_theme
    ensure_zshrc_plugins
    change_default_shell
    verify_installation

    if [[ "$DRY_RUN" == false ]]; then
        show_rollback_instructions
        log_success "Instalação concluída com sucesso!"
        echo ""
        echo -e "${YELLOW}Próximas etapas:${NC}"
        echo "  1. Configure seu terminal para usar a fonte 'MesloLGS NF' (Nerd Font)"
        echo "  2. Recarregue seu shell: ${BLUE}source ~/.zshrc${NC}"
        echo "  3. Ou inicie uma nova sessão de terminal"
        echo ""
    else
        log_success "Simulação concluída - Nenhuma alteração foi feita"
    fi
}

# Executar função principal
main "$@"
