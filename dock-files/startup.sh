#!/bin/bash
ENV=.env
EXAMPLE=.env.example
    if [ -f "$ENV" ] 
    then
        echo "$ENV exists, not creating"
    else
        echo "$ENV doesn't exist, checking for example to copy ..."
        if [ -f "$EXAMPLE" ]
        then
            echo "$EXAMPLE does exist, copying to .env"
            cp .env.example .env
        else
            echo ".env.example not found, .env not created"
        fi
    fi
echo "startup script run, removing existing git hooks ..."
rm ../.git/hooks/*
echo "existing hooks removed, creating new hooks specified in dock-files"
cp -r ../dock-files/hooks/* ../.git/hooks/
echo "hooks created, making new git hooks executable"    
chmod +x ../.git/hooks/*
echo "git hooks created, starting apache service ... "
apachectl -D FOREGROUND