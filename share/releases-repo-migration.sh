#!/bin/bash

function create_readers_group()
{
  set +e
  (
    set -e
    ssh localhost group add site-readers \
        'Users with read access to the site project'
  )
  local ret="$?"
  if [ "$ret" != 0 ]; then
    token=$(ssh localhost group del site-readers 2>&1 | tail -1 | \
        cut -d' ' -f 2)
    ssh localhost group del site-readers $token
  fi
  return $ret
}

function create_writers_group()
{
  set +e
  (
    set -e
    ssh localhost group add site-writers \
        'Users with write access to the site project'
    create_readers_group
  )
  local ret="$?"
  if [ "$ret" != 0 ]; then
    token=$(ssh localhost group del site-writers 2>&1 | tail -1 | \
        cut -d' ' -f 2)
    ssh localhost group del site-writers $token
  fi
  return $ret
}

function create_admins_group()
{
  set +e
  (
    set -e
    ssh localhost group add site-admins \
        'Users with admin access to the site project'
    create_writers_group
  )
  local ret="$?"
  if [ "$ret" != 0 ]; then
    token=$(ssh localhost group del site-admins 2>&1 | tail -1 | \
        cut -d' ' -f 2)
    ssh localhost group del site-admins $token
  fi
  return $ret
}

function create_managers_group()
{
  set +e
  (
    set -e
    ssh localhost group add site-managers \
        'Users with manager access to the site project'
    create_admins_group
  )
  local ret="$?"
  if [ "$ret" != 0 ]; then
    token=$(ssh localhost group del site-managers 2>&1 | tail -1 | \
        cut -d' ' -f 2)
    ssh localhost group del site-managers $token
  fi
  return $ret
}

function link_groups()
{
  set -e
  ssh localhost group addgroup site-admins site-managers
  ssh localhost group addgroup site-writers site-admins
  ssh localhost group addgroup site-readers site-writers
}

function delete_groups()
{
  token=$(ssh localhost group del site-managers 2>&1 | tail -1 | \
      cut -d' ' -f 2)
  ssh localhost group del site-managers $token
  token=$(ssh localhost group del site-admins 2>&1 | tail -1 | \
      cut -d' ' -f 2)
  ssh localhost group del site-admins $token
  token=$(ssh localhost group del site-writers 2>&1 | tail -1 | \
      cut -d' ' -f 2)
  ssh localhost group del site-writers $token
  token=$(ssh localhost group del site-readers 2>&1 | tail -1 | \
      cut -d' ' -f 2)
  ssh localhost group del site-readers $token
}

function create_groups()
{
  # call managers_group which calls admin_group and so on...
  create_managers_group
  set +e
  (
    set -e
    link_groups
  )
  local ret="$?"
  if [ "$ret" != 0 ]; then
    delete_groups
  fi
}

site_groups=$(ssh localhost group list | grep -cE "site-[[:alnum:]]+")
if [ "$site_groups" == 0 ]; then
  create_groups
fi
ssh localhost create "##PREFIX##/site/releases"
description="This is a special repository for distributing release binaries
over HTTP. Visit http://##PREFIX##/releases/ to browse content."
ssh localhost config "##PREFIX##/site/releases" \
    set project.description "$description"

# add a readme to the repository
repo=$(mktemp -d)
git clone ssh://localhost/##PREFIX##/site/releases $repo
cp /usr/share/trove-setup/releases-repo-README $repo/README
cd $repo
git add $repo/README
git commit -m 'Add README'
git push origin master
cd -
rm -Rf $repo
