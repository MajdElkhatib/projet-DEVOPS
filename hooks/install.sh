#!/bin/bash

echo "Installation de pre-commit:"
pip install pre-commit

echo "Version de pre-commit:"
pre-commit --version

echo "Activation des hooks de pre-commit:"
pre-commit install

echo "Fin du script d'installation de pre-commit"
