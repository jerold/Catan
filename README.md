
# Catan Helper
[Click here to use the helper!](http://jerold.github.io/Catan)

The Catan helper allows the user to create a random valid Catan board, or create their own. It then displays the utility values of building plots within that board.

# Deployment

```bash
git checkout gh-pages
git rebase master
pub get
pub build
git add -f build/web && git commit -m "build commit"
git subtree push --prefix build/web origin gh-pages
```
