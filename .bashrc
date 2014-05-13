# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export TERM="xterm-256color"
alias ssh='ssh -A'

rm -f $HOME/.ssh/.ssh-agent-socket
AGENT_SOCKET=$HOME/.ssh/.ssh-agent-socket
AGENT_INFO=$HOME/.ssh/.ssh-agent-info
if [[ -s "$AGENT_INFO" ]]
then
    source $AGENT_INFO
fi

other=0
if [[ -z "$SSH_AGENT_PID" ]]
then
    running=0
else
    running=0
    for u in `ps -C ssh-agent -o pid=`
    do
        if [[ "$running" != "1" ]]
        then
            if [[ "$SSH_AGENT_PID" != "$u" ]]
            then
                running=2
                other=$u
            else
                running=1
                #echo "Agent $u Already Running"
            fi
        fi
    done
fi

if [[ "$running" != "1" ]]
then
    echo "Re-starting Agent"
    killall -15 ssh-agent
    eval `ssh-agent -s -a $AGENT_SOCKET`
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" > $AGENT_INFO
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> $AGENT_INFO
    for file in `ls -1 ~/.ssh/*.pem`
    do
        ssh-add $file
    done
elif [[ "$other" != "0" ]]
then
    if ps -p $other|grep $other|grep defunct >/dev/null
    then
        echo "DEFUNCT process $other is still running"
    else
        echo "WARNING!! non defunct process $other is still running"
    fi
fi

source /etc/profile.d/rvm.sh
PATH=$PATH:/usr/local/rvm/bin # Add RVM to PATH for scripting
