#!/bin/sh
node_modules/coffee-script/bin/coffee -c ./;

#node_modules/jade/bin/jade . -c -r;

for f in ./app/client/views/*.jade ./app/client/views/**/*.jade ./app/client/views/**/partials/*.jade; do
  echo "jade compiled: $f";
  ./node_modules/jade/bin/jade < $f > "${f%.jade}.html";
done;

export NODE_ENV=production;
