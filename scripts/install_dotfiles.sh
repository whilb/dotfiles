git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

DOTFILES_DIR=/home/$USER/.dotfiles/

# TODO what if .old already exist
mv /home/$USER/.bashrc /home/$USER/.bashrc.old
mv /home/$USER/.bash_aliases /home/$USER/.bash_aliases.old
mv /home/$USER/.bash_profile /home/$USER/.bash_profile.old
mv /home/$USER/.tmux.conf /home/$USER/.tmux.conf.old

ln -s $DOTFILES_DIR/.bashrc /home/$USER/.bashrc
ln -s $DOTFILES_DIR/.bash_aliases /home/$USER/.bash_aliases
ln -s $DOTFILES_DIR/.bashrc /home/$USER/.bash_aliases
ln -s $DOTFILES_DIR/.tmux.conf /home/$USER/.tmux.conf

