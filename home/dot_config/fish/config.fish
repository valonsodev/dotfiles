# --- Environment & PATH ---

# SSH Agent
set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# Android SDK
set -x ANDROID_HOME $HOME/Android/Sdk

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

fish_add_path $HOME/code/reverse/tools/jadx/bin

# Go
set -x GOPATH $HOME/go
set -x GOMODCACHE $GOPATH/pkg/mod
set -x GOPROXY https://proxy.golang.org,direct
set -x GOSUMDB sum.golang.org
fish_add_path $GOPATH/bin

# Guard against a broken GOROOT leaking into the environment.
# On Arch (and most distros) you should NOT set GOROOT; the Go tool knows it.
# If GOROOT is set to GOPATH or $HOME/go, stdlib lookups will fail ("package fmt is not in std").
if set -q GOROOT
    if test "$GOROOT" = "$GOPATH"; or test "$GOROOT" = "$HOME/go"
        set -e GOROOT
    end
end

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
    lsd -l -A $argv
end
function tree --description 'lsd --tree' -w lsd
    lsd --tree $argv
end

# function cd --description 'Never again cd, use z' -w cd
#     builtin cd $argv
# end

function mkdir --description 'mkdir -p always' -w mkdir
    command mkdir -p $argv
end

function ipa --description 'List all ips, briefly' -w ip
    command ip --color -br addr show
end

function nano --description 'Use micro instead of nano' -w micro
    micro $argv
end

# function find --description 'Use fd instead of find' -w fd
#     fd $argv
# end

function lines --description 'Print line numbers with wc -l' -w wc
    command wc -l $argv
end

# function grep --description 'Use rg instead of grep' -w rg
#     rg $argv
# end

# function cat --description 'Use bat instead of cat' -w bat
#     bat $argv
# end

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
    command cd $path
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

function kanidm --description 'Run kanidm in a Docker container'
    if not test $HOME/.config/kanidm
        mkdir -p $HOME/.config/kanidm
    end
    if not test $HOME/.cache/kanidm_tokens
        touch $HOME/.cache/kanidm_tokens
    end

    docker run --rm -i -t \
       --network host \
       --mount "type=bind,src=$HOME/.config/kanidm,target=/root/.config/kanidm" \
       --mount "type=bind,src=$HOME/.cache/kanidm_tokens,target=/root/.cache/kanidm_tokens" \
       kanidm/tools:latest \
       /sbin/kanidm $argv
end


function yolo --description 'Git add, commit with timestamp + random openssl hex message (optional repo path, use "remote" or "r" to push)'
    set -l target_dir (pwd)
    set -l do_push 0

    for arg in $argv
        if test "$arg" = remote; or test "$arg" = r
            set do_push 1
        else if test -d "$arg"
            set target_dir $arg
        end
    end
    if test $do_push -eq 1
        echo "remote ENABLED"
    else
        echo "remote DISABLED"
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

    set -l hex (openssl rand -hex 12 2>/dev/null)
    if test -z "$hex"
        echo "Failed to generate random message"
        return 1
    end

    set -l stamp (date "+%H:%M %d/%m/%Y")
    set -l msg "$stamp  -  $hex"


    git -C $target_dir add -A
    git -C $target_dir commit -m "$msg"
    if test $do_push -eq 1
        git -C $target_dir push origin main
    else
    end
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
    if test (hostname) = "stargazer"
        return
    end
    set -l phrases \
    "This world is a buggy program. So it cries out for the flame." \
    "Darkness and obscurity are banished by artificial lighting, and the seasons by air conditioning.\n\nNight and summer are losing their charm and dawn is disappearing.\n\nThe urban population think they have escaped from cosmic reality, but there is no corresponding expansion of their dream life.\n\nThe reason is clear: dreams spring from reality and are realized in it." \
    "Quizás lo que nos une son las baddies que fumbleamos por el camino." \
    "Pray for a world where children become wolves."
    echo -e (random choice $phrases) "\n"
end

set -g __prompt_user (whoami)
set -g __prompt_host (hostname -s)

function fish_prompt --description 'Custom prompt: user@host path git:(branch)->'
    set -l last_status $status
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

    printf '%s%s%s@%s%s %s%s%s%s%s %s->%s ' \
        "$c_user" "$__prompt_user" "$c_norm" "$c_host" "$__prompt_host" \
        "$c_path" "$cwd" "$c_norm" "$git_segment" "$status_segment" \
        "$c_arrow" "$c_norm"
end

function lab --description 'Manage homelab git repos: default commit/push changed ones, `lab sync` pulls all'
    set -l base_dir $HOME/code/homelab
    if not test -d $base_dir
        echo "Homelab directory not found: $base_dir"
        return 1
    end

    # Mode detection (default=changes, alt=sync)
    set -l mode changes
    if test (count $argv) -ge 1
        if test "$argv[1]" = sync
            set mode sync
        end
    end

    # Collect repositories (one or two levels deep)
    set -l repos
    for dir in $base_dir/*/
        if test -d $dir/.git
            set repos $repos $dir
        else
            for subdir in $dir/*/
                if test -d $subdir/.git
                    set repos $repos $subdir
                end
            end
        end
    end

    if test -z "$repos"
        echo "No repositories found under $base_dir"
        return 0
    end

    if test $mode = sync
        # Ensure each repo has origin/main upstream (without changing current HEAD)
        for repo in $repos
            # Skip if no origin remote
            if not git -C $repo remote get-url origin >/dev/null 2>&1
                continue
            end
            # Check if origin has main
            if git -C $repo ls-remote --exit-code --heads origin main >/dev/null 2>&1
                # Create local main if missing (without checkout)
                if not git -C $repo rev-parse --verify main >/dev/null 2>&1
                    echo "[lab] Creating local 'main' in $repo"
                    git -C $repo branch main origin/main >/dev/null 2>&1
                end
                # Ensure upstream tracking for local main
                if git -C $repo rev-parse --verify main >/dev/null 2>&1
                    set -l upstream (git -C $repo for-each-ref --format='%(upstream:short)' refs/heads/main 2>/dev/null)
                    if test -z "$upstream"
                        git -C $repo branch --set-upstream-to=origin/main main >/dev/null 2>&1
                    end
                end
            end
        end
        set -l synced 0
        for repo in $repos
            echo "Pulling: $repo"
            git -C $repo pull --ff-only 2>/dev/null
            set synced (math $synced + 1)
        end
        echo "Synced $synced repositories."
        return 0
    end

    # Default mode: act only on repositories with local changes
    set -l updated 0
    for repo in $repos
        set -l changes (git -C $repo status --porcelain 2>/dev/null)
        if test -n "$changes"
            echo "Processing repository with changes: $repo"
            yolo remote $repo
            set updated (math $updated + 1)
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

function reflect --description 'Update Arch and EndeavourOS mirrorlists'
    sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    if type -q eos-rankmirrors
        sudo eos-rankmirrors --verbose --sort rate
    end
end

function pacsync --description 'Sync pacman repositories'
    yay -Sy
end

# --- Shell integrations ---
if status is-interactive
    zoxide init fish | source

    atuin init fish | source
    bind up _atuin_bind_up

    fnm env --use-on-cd --shell fish | source

    set -g fish_handle_reflow 0
end
