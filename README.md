# Cloud9 Development Environment

This image contains a complete development environment utilizing Cloud9 IDE inside a Ubuntu container to provide everything needed to setup a development environment. It includes Cloud9, but also adds some common utilities in Ubuntu, Vim, and Git.

## Usage

```
docker run -d \ 
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/dev-env-home/:/root \
  -v ~/workspace/:/workspace \
  -p 8000-8020:8000-8020 \
  -e C9USER=user -e C9PASS=welcome -e C9PORT=8888 \
  -p 8888:8888 \
  fluidbyte/c9-dev-env
```

The above does the following (line-by-line):

```
-v /var/run/docker.sock:/var/run/docker.sock
```

**Mounts the host's docker socket into the container**

_This passes the socket through so `docker` in the container uses the host's socket. This preserves images and allows docker to run inside a container._

```
-v ~/dev-env-home/:/root
```

**Mounts the host's `~/dev-env-home` to the container's `/root` home**
_Since the container doesn't maintain state, this allows you to setup your bash profile, aliases, git config, vim config, etc and retain them on the host when the container is stopped_

```
-v ~/workspace/:/workspace
```

**Mounts the host's `~/workspace` to the `/workspace` volume in the container**

_Similar to the line above, this saves the files in the dev environment to the host so they are not lost when the container is stopped._

```
-p 8000-8020:8000-8020
```

**Exposes `8000-8020` for use during development**

_This is optional, but setting a range of open ports allows you to utilize these, for example, when testing a running service in the dev environment._

```
-e C9USER=user -e C9PASS=welcome -e C9PORT=8888
```

**Sets the `C9USER`, `C9PASS` and `C9PORT` settings on which Cloud9 will run**

_The `C9USER` and `C9PASS` will be used to authenticate, the `C9PORT` instructs what port the server should run over._

```
p 8888:8888
```

**Exposes the port set by `C9PORT` making the IDE accessible locally**

_Makes C9 available locally at the port designated_

## Home Directory and User Customization

As mentioned above, you can mount a folder on the host to the container's `/root`. This will allow you to configure Git, Vim, Bash, etc.

For example, you can customize bash by creating a `.bash_profile` with the following:

```bash
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
```

Then a basic `.bashrc` with Git support:

```bash
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

export PS1="[\[\e[34m\]\@\[\e[m\]][\[\e[36m\]\w\[\e[m\]]\`parse_git_branch\`> "

```

The above would give you a prompt like the following:

```
[06:40 PM][~/dir][master]> 
```
