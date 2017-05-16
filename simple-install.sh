echo "in this script, u will:"
echo "install rvm (which manage ruby version)"
echo "install ruby 2.3.1"
echo 'install gem flow-cli'
echo 'using gem mirror ruby-china.org'

echo "Install RVM"
echo "---------------------------------------------------------------------------"

echo "Please enter any key to continue... ctrl-c to QUIT"
read input

which rvm &>/dev/null
if [ $? -ne 0 ]; then
  command gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  command curl -L https://get.rvm.io | bash -s stable
  if [ whoami = 'root']; then
    command source /etc/profile.d/rvm.sh
  else
    command source ~/.rvm/scripts/rvm
  fi
else
  echo "rvm has installed"
fi

rvm requirements
rvm install 2.3.1 --disable-binary
rvm use 2.3.1 --default
rvm -v
ruby -v

gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/

gem install bundler
bundle -v
gem install flow-cli
echo "--------------------------- Install Successed -----------------------------"
