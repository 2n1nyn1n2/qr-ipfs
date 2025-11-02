# to make only one version

    rm -rf .git;
    git init;
    git checkout -b main;
    find . -name ".DS_Store" -depth;
    find . -exec touch {} \;
    git add .;
    git commit -m "Initial commit";
    git tag -a v1.0.0 -m "v1.0.0"
    git remote add origin https://github.com/2n1nyn1n2/qr-ipfs.git;
    git push --follow-tags -u --force origin main;
    git branch --set-upstream-to=origin/main main;
    git pull;git push;

