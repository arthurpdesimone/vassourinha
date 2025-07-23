# Vassourinha - The Ultimate Cleanup Script

**Vassourinha** is a comprehensive and user-friendly shell script designed to help you clean up and reclaim disk space on Debian-based Linux systems (like Ubuntu, Mint, etc.). It provides a clear, interactive, and bilingual (English/Portuguese) interface to perform common and advanced cleanup tasks safely.

---

## English

### Features

-   **Bilingual Interface**: Choose between English or Portuguese at startup.
-   **Visual Disk Usage**: Instantly see your partition usage with a colored progress bar.
-   **Automatic "Run All" Mode**: Execute all safe, non-interactive cleanup tasks with a single command.
-   **Comprehensive Cleanup**: A wide range of options, from basic APT cache cleaning to advanced Docker and AI model cleanup.
-   **Interactive Menus**: Safely manage installed packages, virtual environments, and other potentially sensitive data with clear, interactive prompts.
-   **Safe by Design**: All potentially destructive operations require user confirmation.
-   **Silent Logging**: Every action is logged to `vassourinha.log` for review, without cluttering the terminal.

### How to Use

1.  **Download the Script**: Save the script code into a file named `vassourinha.sh`.

2.  **Make it Executable**: Open your terminal and run the following command:
    ```bash
    chmod +x vassourinha.sh
    ```

3.  **Run the Script**: Execute it from your terminal:
    ```bash
    ./vassourinha.sh
    ```
    The script will first ask for your preferred language and then display the main menu.

### Cleanup Options

#### Automatic Cleanup (`a`)

-   **Run All Automatic Cleanups**: Executes all safe tasks (1, 2, 3, 4, 5, 6, 11, 12, 13) sequentially. Ideal for a quick, general cleanup.

#### Safe Cleanup Tasks (1-6, 11-13)

-   `1. Clean APT Cache`: Removes downloaded package files (`.deb`).
-   `2. Remove Unused Dependencies`: Runs `apt autoremove` to uninstall orphaned packages.
-   `3. Vacuum Systemd Journal Logs`: Reduces the size of system logs.
-   `4. Clear User Cache`: Empties the `~/.cache` directory.
-   `5. Clear Temporary Files`: Empties the `/tmp` directory.
-   `6. Remove Old Snap Versions`: Deletes old, disabled versions of Snap packages.
-   `11. Clean Thumbnail Cache`: Deletes the cache for file and video thumbnails.
-   `12. Remove Old Archived Logs`: Deletes rotated log files (`.gz`, `.1`, etc.) from `/var/log`.
-   `13. Clean unused Flatpaks`: Removes unused Flatpak runtimes if Flatpak is installed.

#### Interactive / Potentially Destructive Cleanups (7-10)

These options require your careful attention and confirmation.

-   `7. Remove Python Virtual Envs`: Scans your home directory for Python virtual environments (`venv`), lists them with their sizes, and asks for confirmation before deleting them all.
-   `8. Full Docker Cleanup`: Prunes the entire Docker system, removing all unused containers, networks, and images (including dangling ones).
-   `9. Remove Ollama Models`: Deletes all downloaded AI models from the Ollama directory (`~/.ollama/models`).
-   `10. Manage Installed Packages`: Lists all packages you installed manually, sorted by size. You can then select a package to view its dependencies or to uninstall it completely.

---

## Português

### Funcionalidades

-   **Interface Bilíngue**: Escolha entre Português ou Inglês ao iniciar.
-   **Uso de Disco Visual**: Veja instantaneamente o uso da sua partição com uma barra de progresso colorida.
-   **Modo Automático "Passar o Rodo"**: Execute todas as tarefas de limpeza seguras e não interativas com um único comando.
-   **Limpeza Abrangente**: Uma vasta gama de opções, desde a limpeza básica do cache do APT até a limpeza avançada de Docker e modelos de IA.
-   **Menus Interativos**: Gerencie com segurança pacotes instalados, ambientes virtuais e outros dados potencialmente sensíveis com menus interativos e claros.
-   **Seguro por Natureza**: Todas as operações potencialmente destrutivas exigem a confirmação do usuário.
-   **Log Silencioso**: Cada ação é registrada no arquivo `vassourinha.log` para revisão, sem poluir o terminal.

### Como Usar

1.  **Baixe o Script**: Salve o código do script em um arquivo chamado `vassourinha.sh`.

2.  **Torne-o Executável**: Abra seu terminal e execute o seguinte comando:
    ```bash
    chmod +x vassourinha.sh
    ```

3.  **Execute o Script**: Rode-o a partir do seu terminal:
    ```bash
    ./vassourinha.sh
    ```
    O script primeiro perguntará qual seu idioma de preferência e depois exibirá o menu principal.

### Opções de Limpeza

#### Limpeza Automática (`a`)

-   **Passar o Rodo (Limpeza Automática)**: Executa todas as tarefas seguras (1, 2, 3, 4, 5, 6, 11, 12, 13) em sequência. Ideal para uma limpeza geral e rápida.

#### Tarefas de Limpeza Seguras (1-6, 11-13)

-   `1. Limpar Cache do APT`: Remove os pacotes (`.deb`) baixados.
-   `2. Remover Dependências Inutilizadas`: Roda `apt autoremove` para desinstalar pacotes órfãos.
-   `3. Limpar Logs do Systemd (Journal)`: Reduz o tamanho dos logs do sistema.
-   `4. Limpar Cache do Usuário`: Esvazia o diretório `~/.cache`.
-   `5. Limpar Arquivos Temporários`: Esvazia o diretório `/tmp`.
-   `6. Remover Versões Antigas de Snaps`: Apaga versões antigas e desabilitadas de pacotes Snap.
-   `11. Limpar Cache de Miniaturas`: Apaga o cache de miniaturas de imagens e vídeos.
-   `12. Remover Logs Antigos Arquivados`: Apaga arquivos de log rotacionados (`.gz`, `.1`, etc.) de `/var/log`.
-   `13. Limpar Flatpaks não utilizados`: Remove runtimes do Flatpak sem uso, se o Flatpak estiver instalado.

#### Limpezas Interativas / Potencialmente Destrutivas (7-10)

Estas opções exigem sua atenção e confirmação.

-   `7. Remover Ambientes Virtuais Python`: Procura por ambientes virtuais Python (`venv`) no seu diretório home, lista-os com seus tamanhos e pede confirmação antes de apagar todos.
-   `8. Limpeza Completa do Docker`: Faz uma limpeza completa do sistema Docker, removendo todos os containers, redes e imagens sem uso (incluindo as "dangling").
-   `9. Remover Modelos do Ollama`: Apaga todos os modelos de IA baixados do diretório do Ollama (`~/.ollama/models`).
-   `10. Gerenciar Pacotes Instalados`: Lista todos os pacotes que você instalou manualmente, ordenados por tamanho. Você pode então selecionar um pacote para ver suas dependências ou para desinstalá-lo completamente.
