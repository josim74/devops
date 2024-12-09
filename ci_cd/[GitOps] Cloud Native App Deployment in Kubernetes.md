
## Prepare Git repo
#### 1. Forke tow repositories with all branches -
1. iac-vprofile [https://github.com/hkhcoder/iac-vprofile]
2. vprofile-action [https://github.com/hkhcoder/vprofile-action]
#### 2. Clone the both repositories
1.  Generate and set ssh key to the git account
2. Set env variable `export GIT_SSH_COMMAND="ssh -i ~/.ssh/<private key fille>"`
3. Configure git for each repo
```bash
cd <cloned repo>
git config core.sshCommand "ssh -i ~/.ssh/<private key fille>"
git config --global user.name josim74
```
