#!/bin/bash

if (( ${BASH_VERSION%%.*} < 4 )); then
    echo 'Bash 4 is required!';
    exit 0;
fi

source ./config.cfg
workspace_path="${PWD}/workspace"

# Creating temporary local repo
rm -rf workspace
rm -rf monorepo
mkdir workspace
cd workspace
for repo_name in "${!repos[@]}"
do
    git clone ${repos[$repo_name]} $repo_name
    cd $repo_name

    for branch_name in "${branches[@]}"
    do  
        if  git ls-remote --heads ${repos[$repo_name]} $branch_name | grep -q $branch_name; then
            git branch --track $branch_name origin/$branch_name
            git checkout $branch_name && git fetch && git pull
        fi
    done
    git fetch --all
    git pull --all
    cd ..
done

# Rewrinting git history moving the files to subfolder
for repo_name in "${!repos[@]}"
do
    cd $repo_name
    echo "Rewrinting ${repos[$repo_name]}"
    for branch_name in "${branches[@]}"
    do
        echo "Rewrinting ${repos[$repo_name]}/${branch_name}"
        if  git branch | grep -q $branch_name; then
            git checkout $branch_name
            git filter-branch -f --index-filter "git ls-files -s | sed \"s|	\(.*\)|	${repo_name}/\1|\" | GIT_INDEX_FILE=\$GIT_INDEX_FILE.new git update-index --index-info && mv \"\$GIT_INDEX_FILE.new\" \"\$GIT_INDEX_FILE\""
        fi
    done
    cd ..
done

cd ..

# Creating new repo
mkdir monorepo
cd monorepo
git init
touch README_temp.md
git add .
git commit -m "Initial commit"

git checkout -b $commom_branch

# Creating branchs
for branch_name in "${branches[@]}"
do
    git checkout $commom_branch
    git checkout -b $branch_name
done

for repo_name in "${!repos[@]}"
do
    git remote add -f $repo_name $workspace_path/$repo_name
    git checkout $commom_branch

    for branch_name in "${branches[@]}"
    do
        git checkout $branch_name
        # Merging repo branchs
        if  git ls-remote --heads $workspace_path/$repo_name $branch_name | grep -q $branch_name; then
            git merge --allow-unrelated-histories --no-edit $repo_name/$branch_name
        # TODO add fallback branch
        #else
            #git merge --allow-unrelated-histories --no-edit $repo_name/develop
            #git add --all && git commit -m "merge ${repo_name} / ${branch_name}" 
        fi
    done
done

git checkout $commom_branch

mv README_temp.md README.md
git add --all && git commit -m "Rename readme.md"