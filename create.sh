#!/bin/bash

while getopts p:y:j:h flag
do
    case "${flag}" in
        p) echo "<?php ?>" > ${OPTARG}.php;;
        y) echo "if __name__ == '__main__':\n print('do something'')"  > ${OPTARG}.py;;
        j) echo "console.log('test')" > ${OPTARG}.js;;
        h) echo "
desc: this utility create file
statement:
  -p : php file
  -y : python file
  -j : js file
  -h : help
  ";;
    esac
done
