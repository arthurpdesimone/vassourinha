#!/bin/bash

# Vassourinha - Um script de limpeza para sistemas baseados em Debian.
# Este script exibe o uso de disco da partição principal, apresenta um menu com
# operações comuns de limpeza e executa o comando selecionado. Todas as ações
# são registradas em um arquivo chamado 'vassourinha.log'.

# --- Configuração ---
LOG_FILE="vassourinha.log"
PARTITION_TO_CHECK="/"

# --- Cores (Códigos de Escape ANSI) ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_MAGENTA='\033[0;35m'
C_CYAN='\033[0;36m'
C_WHITE='\033[0;37m'
C_BOLD='\033[1m'

# --- Configuração do Log ---
# Garante que o arquivo de log exista
touch "$LOG_FILE"

log_message() {
    # Registra uma mensagem no arquivo de log com data e hora.
    # $1: A mensagem a ser registrada.
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# --- Funções de Idioma ---

load_language_strings() {
    local lang="$1"
    if [[ "$lang" == "pt" ]]; then
        # --- Textos em Português ---
        L_SUDO_WARNING="Aviso: Alguns comandos exigem privilégios de root (sudo). Sua senha pode ser solicitada."
        L_DISK_USAGE_TITLE="Uso do Disco"
        L_DISK_USAGE_USED="Usado"
        L_DISK_USAGE_TOTAL="Total"
        L_MENU_HEADER_OPT="Opção"
        L_MENU_HEADER_CMD="Comando"
        L_MENU_HEADER_DESC="Descrição"
        L_MENU_PROMPT="Digite sua escolha"
        L_MENU_OPT1_TITLE="Limpar Cache do APT"
        L_MENU_OPT1_DESC="Remove os pacotes (.deb) baixados."
        L_MENU_OPT2_TITLE="Remover Dependências Inutilizadas"
        L_MENU_OPT2_DESC="Remove pacotes que não são mais necessários."
        L_MENU_OPT3_TITLE="Limpar Logs do Systemd (Journal)"
        L_MENU_OPT3_DESC="Reduz os logs para no máximo 100MB."
        L_MENU_OPT4_TITLE="Limpar Cache do Usuário"
        L_MENU_OPT4_DESC="Apaga o conteúdo da pasta ~/.cache."
        L_MENU_OPT5_TITLE="Limpar Arquivos Temporários"
        L_MENU_OPT5_DESC="Apaga o conteúdo da pasta /tmp."
        L_MENU_OPT6_TITLE="Remover Versões Antigas de Snaps"
        L_MENU_OPT6_DESC="Remove versões antigas e desabilitadas de snaps."
        L_MENU_OPT7_TITLE="Remover Ambientes Virtuais Python"
        L_MENU_OPT7_DESC="Procura e remove ambientes virtuais Python."
        L_MENU_OPT8_TITLE="Limpeza Completa do Docker"
        L_MENU_OPT8_DESC="Remove containers, imagens e redes sem uso."
        L_MENU_OPT9_TITLE="Remover Modelos do Ollama"
        L_MENU_OPT9_DESC="Apaga todos os modelos de IA do Ollama."
        L_MENU_OPT10_TITLE="Gerenciar Pacotes Instalados"
        L_MENU_OPT10_DESC="Lista, detalha e remove pacotes manuais."
        L_MENU_OPT11_TITLE="Limpar Cache de Miniaturas"
        L_MENU_OPT11_DESC="Apaga o cache de miniaturas de imagens/vídeos."
        L_MENU_OPT12_TITLE="Remover Logs Antigos Arquivados"
        L_MENU_OPT12_DESC="Apaga logs antigos (.gz, .1, etc.) em /var/log."
        L_MENU_OPT13_TITLE="Limpar Flatpaks não utilizados"
        L_MENU_OPT13_DESC="Remove runtimes e apps Flatpak órfãos."
        L_MENU_OPT_ALL_TITLE="Passar o Rodo (Limpeza Automática)"
        L_MENU_OPT_ALL_DESC="Executa todas as limpezas seguras de uma vez."
        L_MENU_OPT_EXIT="Sair"
        L_MENU_OPT_EXIT_DESC="Sai do script."
        L_MSG_EXECUTING="Executando"
        L_MSG_SUCCESS="concluído com sucesso."
        L_MSG_ERROR="Erro ao executar"
        L_MSG_CHECK_LOG="Verifique o arquivo '${LOG_FILE}' para detalhes."
        L_MSG_INVALID_OPTION="Opção inválida. Por favor, tente novamente."
        L_MSG_EXITING="Saindo. Até logo!"
        L_PROMPT_CONFIRM_DELETE="Tem certeza que deseja apagar TODOS esses itens? Esta ação não pode ser desfeita."
        L_PROMPT_CONFIRM_UNINSTALL="Tem certeza que deseja desinstalar '%s' e seus arquivos de configuração?"
        L_MSG_ACTION_CANCELED="Ação cancelada."
        L_VENV_SCANNING="Procurando por ambientes virtuais (venvs) Python no seu diretório home..."
        L_VENV_WAIT="Isso pode levar um momento."
        L_VENV_NONE_FOUND="Nenhum ambiente virtual Python foi encontrado."
        L_VENV_FOUND_TITLE="Foram encontrados os seguintes ambientes virtuais:"
        L_VENV_TOTAL_SPACE="Espaço total que pode ser liberado:"
        L_VENV_DELETING="Apagando"
        L_VENV_DELETED_SUCCESS="Apagado com sucesso."
        L_VENV_DELETED_ERROR="Erro ao apagar"
        L_VENV_CLEANUP_COMPLETE="Limpeza completa."
        L_DOCKER_NOT_FOUND="Comando 'docker' não encontrado. Pulando esta etapa."
        L_DOCKER_CLEANING="Iniciando limpeza do Docker..."
        L_DOCKER_WARNING="Este comando irá remover todos os dados não utilizados do Docker:"
        L_DOCKER_WARNING_ITEMS=("- Todos os containers parados" "- Todas as redes não utilizadas" "- Todas as imagens sem tag (dangling)" "- Todas as imagens não utilizadas" "- Todo o cache de build")
        L_DOCKER_PROMPT="Deseja continuar com a limpeza completa do Docker?"
        L_OLLAMA_NOT_FOUND="Diretório de modelos do Ollama não encontrado em"
        L_OLLAMA_CLEANING="Iniciando limpeza de modelos Ollama..."
        L_OLLAMA_FOUND_AT="Modelos encontrados em:"
        L_OLLAMA_TOTAL_SIZE="Tamanho total:"
        L_OLLAMA_PROMPT="Tem certeza que deseja apagar TODOS os modelos do Ollama?"
        L_PKG_SCANNING="Buscando pacotes instalados manualmente..."
        L_PKG_NONE_FOUND="Nenhum pacote marcado como instalado manualmente foi encontrado."
        L_PKG_PROMPT="Selecione um pacote para gerenciar (ou 'q' para voltar):"
        L_PKG_TITLE="Pacotes Instalados Manualmente (ordenados por tamanho):"
        L_PKG_MANAGING="Gerenciando o pacote:"
        L_PKG_MENU_DETAILS="Ver Detalhes (Dependências)"
        L_PKG_MENU_UNINSTALL="Desinstalar Pacote"
        L_PKG_MENU_BACK="Voltar à lista de pacotes"
        L_PKG_DETAILS_TITLE="Detalhes para"
        L_PKG_DETAILS_DEPS="Dependências:"
        L_PKG_DETAILS_SIZE="Tamanho Instalado:"
        L_FLATPAK_NOT_FOUND="Comando 'flatpak' não encontrado. Pulando esta etapa."
        L_RUN_ALL_MSG="Executando todas as tarefas de limpeza automática..."
        L_RUN_ALL_COMPLETE="Limpeza automática concluída."
    else
        # --- English Texts ---
        L_SUDO_WARNING="Warning: Some commands require root privileges (sudo). You may be prompted for your password."
        L_DISK_USAGE_TITLE="Disk Usage"
        L_DISK_USAGE_USED="Used"
        L_DISK_USAGE_TOTAL="Total"
        L_MENU_HEADER_OPT="Option"
        L_MENU_HEADER_CMD="Command"
        L_MENU_HEADER_DESC="Description"
        L_MENU_PROMPT="Enter your choice"
        L_MENU_OPT1_TITLE="Clean APT Cache"
        L_MENU_OPT1_DESC="Removes downloaded package files (.deb)."
        L_MENU_OPT2_TITLE="Remove Unused Dependencies"
        L_MENU_OPT2_DESC="Removes packages that are no longer needed."
        L_MENU_OPT3_TITLE="Vacuum Systemd Journal Logs"
        L_MENU_OPT3_DESC="Reduces journal logs to a maximum of 100MB."
        L_MENU_OPT4_TITLE="Clear User Cache"
        L_MENU_OPT4_DESC="Deletes the contents of the ~/.cache folder."
        L_MENU_OPT5_TITLE="Clear Temporary Files"
        L_MENU_OPT5_DESC="Deletes the contents of the /tmp folder."
        L_MENU_OPT6_TITLE="Remove Old Snap Versions"
        L_MENU_OPT6_DESC="Removes old, disabled versions of snaps."
        L_MENU_OPT7_TITLE="Remove Python Virtual Envs"
        L_MENU_OPT7_DESC="Scans for and removes Python virtual envs."
        L_MENU_OPT8_TITLE="Full Docker Cleanup"
        L_MENU_OPT8_DESC="Removes unused containers, images, and networks."
        L_MENU_OPT9_TITLE="Remove Ollama Models"
        L_MENU_OPT9_DESC="Deletes all downloaded Ollama AI models."
        L_MENU_OPT10_TITLE="Manage Installed Packages"
        L_MENU_OPT10_DESC="Lists, details, and removes manual packages."
        L_MENU_OPT11_TITLE="Clean Thumbnail Cache"
        L_MENU_OPT11_DESC="Deletes the image/video thumbnail cache."
        L_MENU_OPT12_TITLE="Remove Old Archived Logs"
        L_MENU_OPT12_DESC="Deletes old logs (.gz, .1, etc.) in /var/log."
        L_MENU_OPT13_TITLE="Clean unused Flatpaks"
        L_MENU_OPT13_DESC="Removes orphaned Flatpak runtimes and apps."
        L_MENU_OPT_ALL_TITLE="Run All Automatic Cleanups"
        L_MENU_OPT_ALL_DESC="Runs all safe cleanup tasks at once."
        L_MENU_OPT_EXIT="Quit"
        L_MENU_OPT_EXIT_DESC="Exits the script."
        L_MSG_EXECUTING="Executing"
        L_MSG_SUCCESS="completed successfully."
        L_MSG_ERROR="Error executing"
        L_MSG_CHECK_LOG="Check the '${LOG_FILE}' file for details."
        L_MSG_INVALID_OPTION="Invalid option. Please try again."
        L_MSG_EXITING="Exiting. Goodbye!"
        L_PROMPT_CONFIRM_DELETE="Are you sure you want to delete ALL of these items? This action cannot be undone."
        L_PROMPT_CONFIRM_UNINSTALL="Are you sure you want to uninstall '%s' and its configuration files?"
        L_MSG_ACTION_CANCELED="Action canceled."
        L_VENV_SCANNING="Scanning for Python virtual environments in your home directory..."
        L_VENV_WAIT="This may take a moment."
        L_VENV_NONE_FOUND="No Python virtual environments were found."
        L_VENV_FOUND_TITLE="The following virtual environments were found:"
        L_VENV_TOTAL_SPACE="Total space that can be freed:"
        L_VENV_DELETING="Deleting"
        L_VENV_DELETED_SUCCESS="Deleted successfully."
        L_VENV_DELETED_ERROR="Error deleting"
        L_VENV_CLEANUP_COMPLETE="Cleanup complete."
        L_DOCKER_NOT_FOUND="Command 'docker' not found. Skipping this step."
        L_DOCKER_CLEANING="Starting Docker cleanup..."
        L_DOCKER_WARNING="This command will remove all unused Docker data:"
        L_DOCKER_WARNING_ITEMS=("- All stopped containers" "- All networks not used by at least one container" "- All dangling images" "- All unused images" "- All build cache")
        L_DOCKER_PROMPT="Do you wish to continue with the full Docker cleanup?"
        L_OLLAMA_NOT_FOUND="Ollama models directory not found at"
        L_OLLAMA_CLEANING="Starting Ollama models cleanup..."
        L_OLLAMA_FOUND_AT="Models found at:"
        L_OLLAMA_TOTAL_SIZE="Total size:"
        L_OLLAMA_PROMPT="Are you sure you want to delete ALL Ollama models?"
        L_PKG_SCANNING="Searching for manually installed packages..."
        L_PKG_NONE_FOUND="No packages marked as manually installed were found."
        L_PKG_PROMPT="Select a package to manage (or 'q' to go back):"
        L_PKG_TITLE="Manually Installed Packages (sorted by size):"
        L_PKG_MANAGING="Managing package:"
        L_PKG_MENU_DETAILS="View Details (Dependencies)"
        L_PKG_MENU_UNINSTALL="Uninstall Package"
        L_PKG_MENU_BACK="Back to package list"
        L_PKG_DETAILS_TITLE="Details for"
        L_PKG_DETAILS_DEPS="Dependencies:"
        L_PKG_DETAILS_SIZE="Installed-Size:"
        L_FLATPAK_NOT_FOUND="Command 'flatpak' not found. Skipping this step."
        L_RUN_ALL_MSG="Running all automatic cleanup tasks..."
        L_RUN_ALL_COMPLETE="Automatic cleanup complete."
    fi
}

select_language() {
    clear
    printf "${C_BOLD}${C_CYAN}"
    cat << "EOF"

 _   _                                _       _           
| | | |                              (_)     | |          
| | | | __ _ ___ ___  ___  _   _ _ __ _ _ __ | |__   __ _ 
| | | |/ _` / __/ __|/ _ \| | | | '__| | '_ \| '_ \ / _` |
\ \_/ / (_| \__ \__ \ (_) | |_| | |  | | | | | | | | (_| |
 \___/ \__,_|___/___/\___/ \__,_|_|  |_|_| |_|_| |_|\__,_|
                                                          
                                                          

EOF
    printf "\n"
    printf "${C_BOLD}Select your language / Selecione seu idioma:${C_RESET}\n"
    printf "1) English\n"
    printf "2) Português\n"
    
    local choice
    while true; do
        read -rp "$(echo -e ${C_BOLD}"[1-2]: "${C_RESET})" choice
        case $choice in
            1)
                load_language_strings "en"
                break
                ;;
            2)
                load_language_strings "pt"
                break
                ;;
            *)
                printf "${C_RED}Invalid option / Opção inválida.${C_RESET}\n"
                ;;
        esac
    done
}

# --- Funções Principais ---

display_disk_usage_bar() {
    # Obtém o uso de disco e o exibe como uma barra de progresso colorida.
    read -r total used free percent < <(df -k --output=size,used,avail,pcent "$PARTITION_TO_CHECK" | tail -n 1)
    total_gb=$(awk "BEGIN {printf \"%.2f\", $total / 1024 / 1024}")
    used_gb=$(awk "BEGIN {printf \"%.2f\", $used / 1024 / 1024}")
    percent_val=${percent%\%}
    local color=$C_GREEN
    if (( $(echo "$percent_val > 90" | bc -l) )); then color=$C_RED; elif (( $(echo "$percent_val > 70" | bc -l) )); then color=$C_YELLOW; fi
    local term_width=$(tput cols)
    local bar_max_width=$((term_width - 45))
    if [ "$bar_max_width" -lt 20 ]; then bar_max_width=20; fi
    local bar_filled_len=$(awk "BEGIN {printf \"%d\", ($percent_val / 100) * $bar_max_width}")
    local bar_filled=""
    for ((i=0; i<bar_filled_len; i++)); do bar_filled+="█"; done
    local bar_empty=""
    for ((i=bar_filled_len; i<bar_max_width; i++)); do bar_empty+="-"; done
    printf "\n${C_BOLD}%s (%s):${C_RESET}\n" "$L_DISK_USAGE_TITLE" "$PARTITION_TO_CHECK"
    printf "${color}%s${C_RESET}" "["
    printf "${color}%s${C_RESET}" "$bar_filled"
    printf "%s" "$bar_empty"
    printf "${color}%s${C_RESET}" "]"
    printf " ${C_BOLD}${percent}${C_RESET} "
    printf "(%s: ${C_BOLD}${used_gb} GB${C_RESET} / %s: ${C_BOLD}${total_gb} GB${C_RESET})\n" "$L_DISK_USAGE_USED" "$L_DISK_USAGE_TOTAL"
}

execute_command() {
    local command="$1"
    local title="$2"
    printf "\n${C_BOLD}${C_CYAN}%s: %s...${C_RESET}\n" "$L_MSG_EXECUTING" "$title"
    log_message "$L_MSG_EXECUTING: $title"
    output=$(eval "$command" 2>&1)
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        printf "${C_BOLD}${C_GREEN}✔ %s %s${C_RESET}\n" "$title" "$L_MSG_SUCCESS"
        log_message "SUCCESS: $title"
    else
        printf "${C_BOLD}${C_RED}✖ %s %s.${C_RESET}\n" "$L_MSG_ERROR" "$title"
        printf "${C_RED}  %s${C_RESET}\n" "$L_MSG_CHECK_LOG"
        log_message "ERROR: $title failed with exit code $exit_code"
    fi
    echo -e "--- Output for '$title' ---\n$output\n--- End Output ---" >> "$LOG_FILE"
}

gerenciar_pacotes() {
    printf "\n${C_BOLD}${C_CYAN}%s${C_RESET}\n" "$L_PKG_SCANNING"
    local pacotes_manuais_com_tamanho
    pacotes_manuais_com_tamanho=$(join <(apt-mark showmanual | sort) <(dpkg-query -Wf '${Package}\t${Installed-Size}\n' | sort))
    if [ -z "$pacotes_manuais_com_tamanho" ]; then
        printf "\n${C_GREEN}%s${C_RESET}\n" "$L_PKG_NONE_FOUND"
        log_message "No manual packages found."
        return
    fi
    local pacotes_ordenados
    pacotes_ordenados=$(echo "$pacotes_manuais_com_tamanho" | sort -k2 -rn)
    declare -a pacotes_formatados
    declare -a pacotes_originais
    while IFS= read -r line; do
        local nome_pacote
        nome_pacote=$(echo "$line" | awk '{print $1}')
        local tamanho_kb
        tamanho_kb=$(echo "$line" | awk '{print $2}')
        if [[ "$tamanho_kb" =~ ^[0-9]+$ ]]; then
            local tamanho_mb
            tamanho_mb=$(awk "BEGIN {printf \"%.2f\", $tamanho_kb / 1024}")
            pacotes_formatados+=("$(printf "%-12s %s" "(${tamanho_mb} MB)" "$nome_pacote")")
            pacotes_originais+=("$nome_pacote")
        fi
    done <<< "$pacotes_ordenados"
    PS3="$(echo -e ${C_BOLD}"$L_PKG_PROMPT "${C_RESET})"
    while true; do
        printf "\n${C_BOLD}%s${C_RESET}\n" "$L_PKG_TITLE"
        select item_formatado in "${pacotes_formatados[@]}" "$L_MENU_OPT_EXIT"; do
            if [[ "$item_formatado" == "$L_MENU_OPT_EXIT" ]]; then return;
            elif [[ -z "$item_formatado" ]]; then printf "${C_RED}%s${C_RESET}\n" "$L_MSG_INVALID_OPTION";
            else
                local pacote=${pacotes_originais[$((REPLY-1))]}
                while true; do
                    printf "\n${C_BOLD}%s ${C_YELLOW}%s${C_RESET}\n" "$L_PKG_MANAGING" "$pacote"
                    printf "1) %s\n" "$L_PKG_MENU_DETAILS"
                    printf "2) %s\n" "$L_PKG_MENU_UNINSTALL"
                    printf "3) %s\n" "$L_PKG_MENU_BACK"
                    read -rp "$(echo -e ${C_BOLD}"$L_MENU_PROMPT [1-3]: "${C_RESET})" acao
                    case $acao in
                        1)
                            printf "\n${C_BOLD}%s ${C_YELLOW}%s${C_RESET}:\n" "$L_PKG_DETAILS_TITLE" "$pacote"
                            printf "  - ${C_BOLD}%s${C_RESET}\n" "$L_PKG_DETAILS_DEPS"
                            apt-cache depends "$pacote" | grep 'Depends:' | awk '{print "    - " $2}' | sort -u
                            ;;
                        2)
                            local prompt_uninstall
                            printf -v prompt_uninstall "$L_PROMPT_CONFIRM_UNINSTALL" "$pacote"
                            read -rp "$(echo -e "\n${C_BOLD}${C_RED}${prompt_uninstall} (s/N): "${C_RESET})" confirm
                            if [[ "$confirm" =~ ^[sS]$ ]]; then
                                execute_command "sudo apt-get remove --purge -y '$pacote'" "$L_PKG_MENU_UNINSTALL $pacote"
                                return 2
                            else
                                printf "${C_YELLOW}%s${C_RESET}\n" "$L_MSG_ACTION_CANCELED"
                            fi
                            ;;
                        3) break;;
                        *) printf "${C_RED}%s${C_RESET}\n" "$L_MSG_INVALID_OPTION";;
                    esac
                done
                break
            fi
        done
    done
}

scan_and_remove_venvs() {
    printf "\n${C_BOLD}${C_CYAN}%s${C_RESET}\n" "$L_VENV_SCANNING"
    printf "${C_YELLOW}%s${C_RESET}\n" "$L_VENV_WAIT"
    log_message "Scanning for Python virtual environments."
    mapfile -t venvs < <(find "$HOME" -name "pyvenv.cfg" -type f -printf "%h\n" 2>/dev/null)
    if [ ${#venvs[@]} -eq 0 ]; then
        printf "\n${C_GREEN}%s${C_RESET}\n" "$L_VENV_NONE_FOUND"
        log_message "No venvs found."
        return
    fi
    printf "\n${C_BOLD}%s${C_RESET}\n" "$L_VENV_FOUND_TITLE"
    printf "%s\n" "------------------------------------------------------------------"
    local total_size_bytes=0
    for venv_path in "${venvs[@]}"; do
        if [ -d "$venv_path" ]; then
            local size_human
            size_human=$(du -sh "$venv_path" | awk '{print $1}')
            local size_bytes
            size_bytes=$(du -sb "$venv_path" | awk '{print $1}')
            total_size_bytes=$((total_size_bytes + size_bytes))
            printf "  - %-60s ${C_BOLD}${C_YELLOW}(%s)${C_RESET}\n" "$venv_path" "$size_human"
        fi
    done
    printf "%s\n" "------------------------------------------------------------------"
    local total_size_human
    total_size_human=$(numfmt --to=iec-i --suffix=B --format="%.2f" $total_size_bytes)
    printf "${C_BOLD}%s ${C_GREEN}%s${C_RESET}\n" "$L_VENV_TOTAL_SPACE" "$total_size_human"
    read -rp "$(echo -e "\n${C_BOLD}${C_RED}${L_PROMPT_CONFIRM_DELETE} (s/N): "${C_RESET})" confirm
    if [[ "$confirm" =~ ^[sS]$ ]]; then
        printf "\n"
        log_message "User confirmed deletion of ${#venvs[@]} venvs."
        for venv_path in "${venvs[@]}"; do
            printf "%s %s...\n" "$L_VENV_DELETING" "$venv_path"
            rm -rf "$venv_path"
            if [ $? -eq 0 ]; then
                printf "${C_GREEN}✔ %s${C_RESET}\n" "$L_VENV_DELETED_SUCCESS"
                log_message "SUCCESS: Deleted venv at $venv_path"
            else
                printf "${C_RED}✖ %s %s.${C_RESET}\n" "$L_VENV_DELETED_ERROR" "$venv_path"
                log_message "ERROR: Failed to delete venv at $venv_path"
            fi
        done
        printf "\n${C_BOLD}${C_GREEN}%s${C_RESET}\n" "$L_VENV_CLEANUP_COMPLETE"
    else
        printf "\n${C_YELLOW}%s${C_RESET}\n" "$L_MSG_ACTION_CANCELED"
        log_message "User canceled venv deletion."
    fi
}

limpar_docker() {
    if ! command -v docker &> /dev/null; then
        printf "\n${C_YELLOW}%s${C_RESET}\n" "$L_DOCKER_NOT_FOUND"
        log_message "Docker not found."
        return
    fi
    printf "\n${C_BOLD}${C_CYAN}%s${C_RESET}\n" "$L_DOCKER_CLEANING"
    printf "${C_YELLOW}%s${C_RESET}\n" "$L_DOCKER_WARNING"
    for item in "${L_DOCKER_WARNING_ITEMS[@]}"; do
        printf "${C_YELLOW}%s${C_RESET}\n" "$item"
    done
    read -rp "$(echo -e "\n${C_BOLD}${C_RED}${L_DOCKER_PROMPT} (s/N): "${C_RESET})" confirm
    if [[ "$confirm" =~ ^[sS]$ ]]; then
        execute_command "sudo docker system prune -a -f" "$L_MENU_OPT8_TITLE"
    else
        printf "\n${C_YELLOW}%s${C_RESET}\n" "$L_MSG_ACTION_CANCELED"
        log_message "User canceled Docker cleanup."
    fi
}

limpar_ollama() {
    local ollama_path="$HOME/.ollama/models"
    if [ ! -d "$ollama_path" ]; then
        printf "\n${C_YELLOW}%s '${ollama_path}'.${C_RESET}\n" "$L_OLLAMA_NOT_FOUND"
        log_message "Ollama directory not found."
        return
    fi
    printf "\n${C_BOLD}${C_CYAN}%s${C_RESET}\n" "$L_OLLAMA_CLEANING"
    local size_human
    size_human=$(du -sh "$ollama_path" | awk '{print $1}')
    printf "%s ${C_YELLOW}%s${C_RESET} (%s ${C_BOLD}%s${C_RESET})\n" "$L_OLLAMA_FOUND_AT" "$ollama_path" "$L_OLLAMA_TOTAL_SIZE" "$size_human"
    read -rp "$(echo -e "\n${C_BOLD}${C_RED}${L_OLLAMA_PROMPT} (s/N): "${C_RESET})" confirm
    if [[ "$confirm" =~ ^[sS]$ ]]; then
        execute_command "rm -rf '$ollama_path'" "$L_MENU_OPT9_TITLE"
    else
        printf "\n${C_YELLOW}%s${C_RESET}\n" "$L_MSG_ACTION_CANCELED"
        log_message "User canceled Ollama cleanup."
    fi
}

limpar_thumbnails() {
    execute_command "rm -rf ${HOME}/.cache/thumbnails/*" "$L_MENU_OPT11_TITLE"
}

limpar_logs_antigos() {
    execute_command "sudo find /var/log -type f -regex '.*\.\(gz\|[0-9]\)$' -delete" "$L_MENU_OPT12_TITLE"
}

limpar_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        printf "\n${C_YELLOW}%s${C_RESET}\n" "$L_FLATPAK_NOT_FOUND"
        log_message "Flatpak not found."
        return
    fi
    execute_command "flatpak uninstall --unused -y" "$L_MENU_OPT13_TITLE"
}

run_all_silent() {
    printf "\n${C_BOLD}${C_CYAN}%s${C_RESET}\n" "$L_RUN_ALL_MSG"
    execute_command "sudo apt-get clean" "$L_MENU_OPT1_TITLE"
    execute_command "sudo apt-get autoremove --purge -y" "$L_MENU_OPT2_TITLE"
    execute_command "sudo journalctl --vacuum-size=100M" "$L_MENU_OPT3_TITLE"
    execute_command "rm -rf ${HOME}/.cache/*" "$L_MENU_OPT4_TITLE"
    limpar_thumbnails
    execute_command "sudo rm -rf /tmp/*" "$L_MENU_OPT5_TITLE"
    local snap_cleanup_cmd="snap list --all | awk '/disabled|desativado/{print \$1, \$3}' | while read snapname revision; do sudo snap remove \"\$snapname\" --revision=\"\$revision\"; done"
    execute_command "$snap_cleanup_cmd" "$L_MENU_OPT6_TITLE"
    limpar_logs_antigos
    limpar_flatpak
    printf "\n${C_BOLD}${C_GREEN}%s${C_RESET}\n" "$L_RUN_ALL_COMPLETE"
}

show_menu() {
    while true; do
        printf "\n%s\n" "----------------------------------------------------------------------"
        printf "${C_BOLD}%-8s %-32s %s${C_RESET}\n" "$L_MENU_HEADER_OPT" "$L_MENU_HEADER_CMD" "$L_MENU_HEADER_DESC"
        printf "%s\n" "----------------------------------------------------------------------"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "1" "$L_MENU_OPT1_TITLE" "$L_MENU_OPT1_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "2" "$L_MENU_OPT2_TITLE" "$L_MENU_OPT2_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "3" "$L_MENU_OPT3_TITLE" "$L_MENU_OPT3_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "4" "$L_MENU_OPT4_TITLE" "$L_MENU_OPT4_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "5" "$L_MENU_OPT5_TITLE" "$L_MENU_OPT5_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "6" "$L_MENU_OPT6_TITLE" "$L_MENU_OPT6_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "11" "$L_MENU_OPT11_TITLE" "$L_MENU_OPT11_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "12" "$L_MENU_OPT12_TITLE" "$L_MENU_OPT12_DESC"
        printf "${C_CYAN}%-8s${C_RESET} %-32s %s\n" "13" "$L_MENU_OPT13_TITLE" "$L_MENU_OPT13_DESC"
        printf "\n${C_BOLD}--- ${C_YELLOW}Limpezas Interativas / Perigosas${C_WHITE} ---${C_RESET}\n"
        printf "${C_YELLOW}%-8s${C_RESET} %-32s %s\n" "7" "$L_MENU_OPT7_TITLE" "$L_MENU_OPT7_DESC"
        printf "${C_YELLOW}%-8s${C_RESET} %-32s %s\n" "8" "$L_MENU_OPT8_TITLE" "$L_MENU_OPT8_DESC"
        printf "${C_YELLOW}%-8s${C_RESET} %-32s %s\n" "9" "$L_MENU_OPT9_TITLE" "$L_MENU_OPT9_DESC"
        printf "${C_YELLOW}%-8s${C_RESET} %-32s %s\n" "10" "$L_MENU_OPT10_TITLE" "$L_MENU_OPT10_DESC"
        printf "\n${C_BOLD}--- ${C_GREEN}Automação${C_WHITE} ---${C_RESET}\n"
        printf "${C_GREEN}%-8s${C_RESET} %-32s %s\n" "a" "$L_MENU_OPT_ALL_TITLE" "$L_MENU_OPT_ALL_DESC"
        printf "\n${C_YELLOW}%-8s${C_RESET} %-32s %s\n" "q" "$L_MENU_OPT_EXIT" "$L_MENU_OPT_EXIT_DESC"
        printf "%s\n" "----------------------------------------------------------------------"

        read -rp "$(echo -e ${C_BOLD}"$L_MENU_PROMPT [1-13, a, q]: "${C_RESET})" choice
        case $choice in
            1) execute_command "sudo apt-get clean" "$L_MENU_OPT1_TITLE";;
            2) execute_command "sudo apt-get autoremove --purge -y" "$L_MENU_OPT2_TITLE";;
            3) execute_command "sudo journalctl --vacuum-size=100M" "$L_MENU_OPT3_TITLE";;
            4) execute_command "rm -rf ${HOME}/.cache/*" "$L_MENU_OPT4_TITLE";;
            5) execute_command "sudo rm -rf /tmp/*" "$L_MENU_OPT5_TITLE";;
            6)
                local snap_cleanup_cmd="snap list --all | awk '/disabled|desativado/{print \$1, \$3}' | while read snapname revision; do sudo snap remove \"\$snapname\" --revision=\"\$revision\"; done"
                execute_command "$snap_cleanup_cmd" "$L_MENU_OPT6_TITLE"
                ;;
            7) scan_and_remove_venvs;;
            8) limpar_docker;;
            9) limpar_ollama;;
            10) gerenciar_pacotes;;
            11) limpar_thumbnails;;
            12) limpar_logs_antigos;;
            13) limpar_flatpak;;
            a|A) run_all_silent;;
            q|Q)
                printf "\n${C_BOLD}${C_YELLOW}%s${C_RESET}\n" "$L_MSG_EXITING"
                break
                ;;
            *)
                printf "\n${C_RED}%s${C_RESET}\n" "$L_MSG_INVALID_OPTION"
                ;;
        esac
        if [[ "$choice" =~ ^[1-9]$|^1[0-3]$|^a$|^A$ ]]; then
            display_disk_usage_bar
        fi
    done
}

# --- Execução Principal do Script ---

select_language
clear
printf "${C_BOLD}${C_CYAN}"
cat << "EOF"

 _   _                                _       _           
| | | |                              (_)     | |          
| | | | __ _ ___ ___  ___  _   _ _ __ _ _ __ | |__   __ _ 
| | | |/ _` / __/ __|/ _ \| | | | '__| | '_ \| '_ \ / _` |
\ \_/ / (_| \__ \__ \ (_) | |_| | |  | | | | | | | | (_| |
 \___/ \__,_|___/___/\___/ \__,_|_|  |_|_| |_|_| |_|\__,_|
                                                          
                                                          

EOF
if [ "$(id -u)" -ne 0 ]; then
    printf "\n${C_BOLD}${C_YELLOW}%s${C_RESET}\n" "$L_SUDO_WARNING"
fi
display_disk_usage_bar
show_menu
