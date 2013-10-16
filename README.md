COBAR SYSTEMS - THEMIS
======================

- Production Server:  http://lyssa.cobarsystems.com/
- Development Server: http://lyssa.cobarsystems.com/

Instructions
------------
- Clone this repository
- Within the repo run: <pre>git submodule init && git submodule update</pre>

Requirements
------------
- Vagrant v1.3.1 (http://downloads.vagrantup.com/tags/v1.3.1)
- Virtual Box (https://www.virtualbox.org/wiki/Downloads)
- Vagrant Host Manager <pre>vagrant plugin install vagrant-hostmanager</pre>
- Within the VM (auto-configured & set up by vagrant)
  - Redis
  - MySQL
  - Node.js v0.8.18

Development Environment Setup
-----------------------------
- Install Node.js/NPM (npm install -g n <-- excellent node version switcher), MySQL server, REDIS server
- Install following packages (globally)
<pre>
  sudo npm install -g ejs
  sudo npm install -g jade
  sudo npm install -g less
  sudo npm install -g coffee-script
  sudo npm install -g nodefront
  sudo npm install -g hbs
  sudo npm install -g marked
  sudo npm install -g sass
</pre>
- MySQL development connection parmeters
<pre>
  HOST: 'localhost'
  USER: 'root'
  PASS: ''
  DATABASE: 'lyssa'
</pre>

Development Initialization
--------------------------
- Start redis-server, mysql-server
- In directory `main/app/server/` run `nodemon server.coffee`
  - nodemon will watch the server directory for changes, restarting node.
  - This will prevent the server from restarting unnecessarily for changes to client-side files
- In directory `main/app` run `nodefront compile -w -r`
  - nodefront will compile (1)jade and (2)coffee-script files, and will alert you whenever you run into a syntax error

Notes on Differences Between Production & Development
--------------------------------------------
Production:
- 1: `./postinstall.sh`
  - Compiles all coffee-script and jade files before initialization of server
- 2: `./main/app/server/bootstrap.js`
  - Runs require.js optimizer. Minifies and combines all CSS/JS files.
  - Renames ouput file to random (but consistent across horizontally-scaled servers) MD5 hash string for
each deployment to break user-agent cache.
  - When optimization complete, bootstrap.js loads server.js

Development:
- 1: `./main/app/server/server.js`
  - Serves uncombined & unminified files via require.js. Browser refreshes pull latest files for development convenience.

Credits
-------
Contributors: [cflynn07](https://github.com/cflynn07)
Boston, MA, United States

Documentation
-------------
- [CONTRIBUTING](CONTRIBUTING.md)
