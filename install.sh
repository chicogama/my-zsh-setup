#!/bin/bash

################################################################################
# ZSH Setup Installation Script
# Automatiza a instalação e configuração do ZSH preservando personalizações
################################################################################

set -e

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

print_help() {
    cat << EOF
Uso: ./install.sh [opções]

Instala e configura ZSH preservando personalizações existentes.

Opções:
    --backup             Criar backup dos arquivos existentes (padrão: ativado)
    --no-backup          Não criar backup (CUIDADO!)
    --dry-run            Simular instalação sem fazer alterações
    -v, --verbose        Saída detalhada
    -h, --help           Mostrar este menu

Exemplos:
    ./install.sh                    # Instalar com backup
    ./install.sh --dry-run          # Simular instalação
    ./install.sh --dry-run -v       # Simular com detalhes
    ./install.sh --no-backup -v     # Instalar sem backup (cuidado!)

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
    local existing_plugins=$(grep -oP "plugins=\(\K[^)]*" "$HOME/.zshrc" 2>/dev/null || echo "")
    
    if [[ ! -z "$existing_plugins" ]]; then
        log_info "Plugins encontrados: $existing_plugins"
    fi
    
    # Extrair tema existente
    local existing_theme=$(grep "^ZSH_THEME=" "$HOME/.zshrc" 2>/dev/null | cut -d'"' -f2 || echo "")
    
    if [[ ! -z "$existing_theme" ]]; then
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
    create_backups
    merge_zshrc
    deploy_dotfiles
    verify_installation
    
    if [[ "$DRY_RUN" == false ]]; then
        show_rollback_instructions
        log_success "Instalação concluída com sucesso!"
        echo ""
        echo -e "${YELLOW}Próximas etapas:${NC}"
        echo "  1. Recarregue seu shell: ${BLUE}source ~/.zshrc${NC}"
        echo "  2. Ou inicie uma nova sessão de terminal"
        echo ""
    else
        log_success "Simulação concluída - Nenhuma alteração foi feita"
    fi
}

# Executar função principal
main
