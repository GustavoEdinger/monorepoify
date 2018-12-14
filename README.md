# Monorepoify

Tool for creating monorepos by merging existing repositories and keeping the history and branches.

## Requirements

- Bash 4
- Git 2.17 (tested)


## Quick start

### Download

First you need to clone/download the repo.

```
git clone https://github.com/DreamlinesGmbH/monorepoify.git
```

### Configuration

You need to fill the file `config.cfg` with the repositories and branches that you want to merge.

```
declare -A repos=(
    ["FOLDER"]="GIT_URL"
    ["FOLDER_2"]="GIT_URL_2"
)
```

- `FOLDER` is the name of the subfolder where the repo files will stay after the merging.
- `GIT_URL` is the address to the repo to merge, works with any kind of address HTTPS, SSH, local...

```
declare -a branches=(
    "develop" 
    "master"
)
```

Here you must add all the branches the want to preserve.

### Building

Then run `./monorepoify.sh` to start the process.

All the commits of all branches that you added in the config file will be rewrited in a temporary repo with the new path (with subfolders) to avoid rename conflits. 

**This process will change the commit hashes.**


### Enjoy monorepo!