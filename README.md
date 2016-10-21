
# Catan Helper
[Click here to use the helper!](http://jerold.github.io/Catan)

The Catan helper allows the user to create a random valid Catan board, or create their own. It then displays the utility values of building plots within that board.

# SASS watcher
```bash
cd Catan/web/
sass --watch css/catan.scss:css/catan.css
```

# Deployment with github.io

```bash
git checkout gh-pages
git rebase master
pub get
pub build
git add -f build/web && git commit -m "build commit"
git push origin --delete gh-pages
git subtree push --prefix build/web origin gh-pages
```

# Server
Requires Go 1.7 to be installed and a GOPATH is setup.
Make sure server is cloned into $GOPATH
Make sure $PATH has $GOPATH/bin in it.

```
./initgo.sh
./runserver.sh
```

If you are working on client code you can regenerated it via
```
./golib/buildclient.sh
```
