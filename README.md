# Client
Either you can just open the `./index.html` itself, or run `npm run devStart` to start a local webserver on port `5173`.
No additional installation required

# Server
Step 1: Install the dependencies by running `npm install` in the `./server` directory

Step 2: Now, create a new file called `.env` in the `./server` directory and add the values in form of the `env-template.txt` file

Step 3: If you want to use SSL / HTTPS, go into the `./server/ssl` directory and run the `generate.cmd` file after you changed the `C`, `ST`, `L`, `O`, `OU`, `CN`, `emailAddress` and `alt_names` fields in the `generate.cnf` file. This will generate a self-signed certificate and key for you. If you don't want to use SSL / HTTPS, just delete the `./server/ssl` directory.

Step 4: Run `npm run nodemon` to start the server.