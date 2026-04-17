# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
alias l='ls -lahrt'

#export JAVA_HOME="/opt/java-se-8u41-ri"
#export PATH=$JAVA_HOME/bin:$PATH

export JAVA_HOME="/opt/jdk-17.0.10"
export PATH=$JAVA_HOME/bin:$PATH


M2_HOME='/opt/apache-maven-3.9.6'
PATH="$M2_HOME/bin:$PATH"
export PATH

#exec zsh
