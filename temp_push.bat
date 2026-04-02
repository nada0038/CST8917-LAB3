cd c:\Users\akash\LAB3
git rm -r --cached .venv --ignore-unmatch
git rm -r --cached .vscode --ignore-unmatch
git rm --cached local.settings.json --ignore-unmatch
git rm --cached image.png --ignore-unmatch
git add .
git commit -m "chore: clean remaining local unwanted files"
git push
