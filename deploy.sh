#!/bin/bash
echo "--------------------------------------"
echo "Deploy New Post"
echo "--------------------------------------"
echo ""
git status
echo ""
git add .
echo ""
git commit -m "deploy new post"
echo ""
git push origin gh_pages:master 
