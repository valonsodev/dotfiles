# --- Environment & PATH ---

# SSH Agent
set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# Android SDK
set -x ANDROID_HOME $HOME/Android/Sdk

# Node Version Manager (sourcing happens later if desired)
set -x NVM_DIR $HOME/.nvm

# PNPM
set -x PNPM_HOME $HOME/.local/share/pnpm
fish_add_path $PNPM_HOME

# Bun
set -x BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin

# Cargo (Rust)
set -x CARGO_HOME $HOME/.cargo
fish_add_path $CARGO_HOME/bin

# Ruby Gems (user)
set -x GEM_HOME $HOME/.local/share/gem/ruby/3.3.0
set -x GEM_PATH $GEM_HOME
fish_add_path $GEM_HOME/bin

# Go
set -x GOROOT $HOME/go
fish_add_path $GOROOT/bin

# Local user tools
fish_add_path $HOME/.local/bin

# Atuin
fish_add_path $HOME/.atuin/bin

# --- FunctionS & ALIASES ---
# When function and subcommand share the same name, use 'command <cmd>' to avoid recursion
abbr -a download_apk '~/code/reverse/tools/apkeep/download.sh'

function ls --description 'Use lsd instead of ls' -w lsd
    lsd -A $argv
end

function ll --description 'Use lsd -l' -w lsd
    lsd -l -a $argv
end
function tree --description 'lsd --tree' -w lsd
    lsd --tree $argv
end

function cd --description 'Never again cd, use z' -w cd
    # Echo a message to use 'z'
    echo "Use 'z' my guy"
    command cd $argv
end

function mkdir --description 'mkdir -p always' -w mkdir
    command mkdir -p $argv
end

function ipa --description 'List all ips, briefly' -w ip
    command ip -br addr show
end

function nano --description 'Use micro instead of nano' -w micro
    micro $argv
end

function find --description 'Use fd instead of find' -w fd
    fd $argv
end

function lines --description 'Print line numbers with wc -l' -w wc
    command wc -l $argv
end

function grep --description 'Use rg instead of grep' -w rg
    rg $argv
end

function cat --description 'Use bat instead of cat' -w bat
    bat $argv
end

function diff --description 'Use delta instead of diff' -w delta
    delta $argv
end

function df --description 'Use duf instead of df' -w duf
    command duf $argv
end

function man --description 'Use tldr instead of man' -w tldr
    tldr $argv
end

function ping --description 'Use gping instead of ping' -w gping
    gping $argv
end
function ps --description 'Use procs instead of ps' -w procs
    procs $argv
end

function c --description 'clear' -w clear
    clear
end

function up --description 'go up n directories' 
    if test (count $argv) -eq 0
        set levels 1
    else
        set levels $argv[1]
    end
    set path ''
    for i in (seq $levels)
        set path $path'../'
    end
    z $path
end

function ff --description 'fastfetch' -w fastfetch
    fastfetch
end

function genpwd --description 'Generate a random password using openssl'
    if test (count $argv) -eq 0
        set length 16
    else
        set length $argv[1]
    end
    openssl rand -hex $length
end

function brokeadb
	sudo adb kill-server
	sudo adb start-server
end

function sudo --description 'Use sudo with !! support' -w sudo
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

function yolo --description 'Git add, commit with timestamp + random openssl hex message (optional repo path)'
    # Optional first arg: target repository directory (defaults to current dir)
    set -l target_dir (pwd)
    if test (count $argv) -ge 1
        set target_dir $argv[1]
    end

    if not test -d $target_dir
        echo "Directory not found: $target_dir"
        return 1
    end

    if not test -d $target_dir/.git
        echo "Not a git repository: $target_dir"
        return 1
    end

    if not type -q openssl
        echo "openssl not found"
        return 1
    end

    # Fixed random length (12 bytes -> 24 hex chars)
    set -l hex (openssl rand -hex 12 2>/dev/null)
    if test -z "$hex"
        echo "Failed to generate random message"
        return 1
    end

    set -l stamp (date "+%H:%M %d/%m/%Y")
    set -l msg "$stamp  -  $hex"

    git -C $target_dir add -A
    git -C $target_dir commit -m "$msg"
    git -C $target_dir push origin main
end

function flush --description 'Flush filesystem buffers (background) and monitor dirty pages'
    command sync &
    watch -n 1 'grep "Dirty" /proc/meminfo'
end

function spawn -d 'Spawns a process, independent from the shell'
  nohup $argv > /dev/null ^ /dev/null &
end

function jar2exec --description 'Create a self-executing jar from a .jar file'
	if test (count $argv) -eq 0
		echo "Usage: jar2exec <jarfile>"
		return 1
	end
	set jarfile $argv[1]
	if not test -f $jarfile
		echo "File not found: $jarfile"
		return 1
	end
	set filename (string replace -r '\\.jar$' '' (basename $jarfile))
	set target_dir "$HOME/.local/bin"
	mkdir -p $target_dir
	# NOTE: This reproduces original behavior, but resulting file won't be a valid self-executing jar on all systems.
	echo '#!/usr/bin/java -jar' > $target_dir/$filename
	cat $jarfile >> $target_dir/$filename
	chmod +x $target_dir/$filename
	echo "Executable created: $target_dir/$filename"
end

function ca --description 'chezmoi apply' -w 'chezmoi apply'
    chezmoi apply --force
end

function code --description 'Open VSCode in current directory' -w 'code'
    if test (count $argv) -eq 0
        command code .
    else
        command code $argv
    end
end
    
# Greeting
function fish_greeting
    set -l phrases \
    "This world is a buggy program. So it cries out for the flame." \
    "Darkness and obscurity are banished by artificial lighting, and the seasons by air conditioning.\n\nNight and summer are losing their charm and dawn is disappearing.\n\nThe urban population think they have escaped from cosmic reality, but there is no corresponding expansion of their dream life.\n\nThe reason is clear: dreams spring from reality and are realized in it." \
    "Quizás lo que nos une son las baddies que fumbleamos por el camino."
    echo -e (random choice $phrases)
end

function fish_prompt --description 'Custom prompt: user@host path git:(branch)->'
    set -l last_status $status
    set -l user (whoami)
    set -l host (hostname -s)
    set -l cwd (prompt_pwd)

    # Git branch detection (check .git directory or file in current dir)
    set -l branch ''
    if test -e .git
        set branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
        if test -z "$branch"
            set branch (command git rev-parse --short HEAD 2>/dev/null)
        end
    end

    # Colors (use inline set_color for clarity in printf)
    set -l c_user (set_color brcyan)
    set -l c_host (set_color brgreen)
    set -l c_path (set_color brblue)
    set -l c_git (set_color brmagenta)
    set -l c_branch (set_color brred)
    set -l c_arrow (set_color bryellow)
    set -l c_err (set_color brred)
    set -l c_norm (set_color normal)

    # Status indicator
    set -l status_segment ''
    if test $last_status -ne 0
        set status_segment (printf ' %s!%s%s' "$c_err" "$last_status" "$c_norm")
    end

    # Git segment
    set -l git_segment ''
    if test -n "$branch"
        # 'git' label in magenta, branch in bright red
        set git_segment (printf ' %sgit:%s(%s%s%s)%s' "$c_git" "$c_norm" "$c_branch" "$branch" "$c_norm" "$c_norm")
    end

    printf '%s%s%s@%s%s %s%s%s%s%s %s\n->%s ' \
        "$c_user" "$user" "$c_norm" "$c_host" "$host" \
        "$c_path" "$cwd" "$c_norm" "$git_segment" "$status_segment" \
        "$c_arrow" "$c_norm"
end

function lab --description 'Sync homelab git repos (only those with changes)'
    set -l base_dir $HOME/code/homelab
    if not test -d $base_dir
        echo "Homelab directory not found: $base_dir"
        return 1
    end

    set -l updated 0
    for dir in $base_dir/*/
        if test -d $dir/.git
            set -l changes (git -C $dir status --porcelain 2>/dev/null)
            if test -n "$changes"
                echo "Processing repository with changes: $dir"
                yolo $dir
                set updated (math $updated + 1)
            end
        end
    end

    if test $updated -eq 0
        echo "No repositories with changes."
    end
end

function duf --description 'Docker compose down, up --force-recreate' -w 'docker compose'
    docker compose down
    docker compose up --force-recreate $argv
end

# --- Shell integrations ---
if status is-interactive
    zoxide init fish | source

    atuin init fish | source
    bind up _atuin_bind_up

    set -g fish_handle_reflow 0
end
