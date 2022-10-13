---
marp: true
theme: uncover
header: 'PROJET FINAL DEVOPS - Pre-commit'
footer: 'Groupe 3'
paginate: true
---

# Pre-commit

---

https://pre-commit.com/

```bash
#!/bin/bash

echo "Installation de pre-commit:"
pip install pre-commit

echo "Version de pre-commit:"
pre-commit --version

echo "Activation des hooks de pre-commit:"
pre-commit install

echo "Pour lancer pre-commit sur tous les fichiers:"
echo "pre-commit run --all-files"
echo "Fin du script d'installation de pre-commit"
```

---
<style scoped>section { font-size: 1.7em; }</style>
https://pre-commit.com/hooks.html

```yaml
# See https://pre-commit.com for more information
# See https://pre-commit.com/hooks.html for more hooks
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.3.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files
    -   id: check-byte-order-marker
    -   id: fix-byte-order-marker
    #-   id: check-executables-have-shebangs
    #-   id: check-shebang-scripts-are-executable
    -   id: check-symlinks
    -   id: destroyed-symlinks
    -   id: forbid-new-submodules
    -   id: check-json
    -   id: check-xml
    -   id: mixed-line-ending
        args: ['--fix=lf']
    -   id: check-case-conflict
    -   id: check-merge-conflict
    -   id: check-vcs-permalinks
    -   id: detect-private-key
    -   id: requirements-txt-fixer
```
