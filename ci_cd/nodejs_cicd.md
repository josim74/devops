



## MongoDB as a Database
    - Install MongoDB
        ```bash
        # Import public key then install
        sudo apt-get install gnupg -y

        curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
        sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
        
        sudo apt-get update -y
        sudo apt-get install -y mongodb-org

        # Check Mongo DB service
        sudo systemctl start mongod
        ```
    - Open Mongo shell to creatre user
        ```
        mongosh
        ```
    - Specify admin database to create user
        ```
        use admin
        ```
    - Create user
        ```
        db.createUser(
            {
                user: "sammy",
                pwd: "your_password",
                roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
            }
        )
        ```
        exit once done
    - Add Mongoose and DB info to the project
        ```
        npm install mongoose
        ```
    - Create node_project/db.js
        ```
        const mongoose = require('mongoose');

        const MONGO_USERNAME = 'sammy';
        const MONGO_PASSWORD = 'your_password';
        const MONGO_HOSTNAME = '127.0.0.1';
        const MONGO_PORT = '27017';
        const MONGO_DB = 'sharkinfo';
        const url = `mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOSTNAME}:${MONGO_PORT}/${MONGO_DB}?authSource=admin`;

        mongoose.connect(url, {useNewUrlParser: true});
        ```
    - Update /node_project/app.js
        ```                                                    
        const express = require('express');
        const app = express();
        const router = express.Router();
        const db = require('./db');

        const path = __dirname + '/views/';
        const port = 8080;

        router.use(function (req,res,next) {
        console.log('/' + req.method);
        next();
        });

        router.get('/', function(req,res){
        res.sendFile(path + 'index.html');
        });

        router.get('/sharks', function(req,res){
        res.sendFile(path + 'sharks.html');
        });

        app.use(express.static(path));
        app.use('/', router);
        ```

    - Creating Mongoose Schemas and Models
        Create models/sharks.js file
        ```
        const mongoose = require('mongoose');
        const Schema = mongoose.Schema;

        const Shark = new Schema ({
                name: { type: String, required: true },
                character: { type: String, required: true },
        });

        module.exports = mongoose.model('Shark', Shark)
        ```
    - Create Controller 'nano controllers/sharks.js'
        ```
        const path = require('path');
        const Shark = require('../models/sharks');

        exports.index = function (req, res) {
            res.sendFile(path.resolve('views/sharks.html'));
        };

        exports.create = function (req, res) {
            var newShark = new Shark(req.body);
            console.log(req.body);
            newShark.save(function (err) {
                    if(err) {
                    res.status(400).send('Unable to save shark to database');
                } else {
                    res.redirect('/sharks/getshark');
                }
        });
                    };

        exports.list = function (req, res) {
                Shark.find({}).exec(function (err, sharks) {
                        if (err) {
                                return res.send(500, err);
                        }
                        res.render('getshark', {
                                sharks: sharks
                    });
                });
        };
        ```
    - Structure should look like this inside 'node_project' dirctory
        ```
        ├── Dockerfile
        ├── README.md
        ├── app.js
        ├── controllers
        │   └── sharks.js
        ├── db.js
        ├── models
        │   └── sharks.js
        ├── package-lock.json
        ├── package.json
        └── views
            ├── css
            │   └── styles.css
            ├── index.html
            └── sharks.html
        ```
    - Using EJS and Express Middleware to /node_project/app.js to collection and rendar data
        ```
        // Above express.static() function
        app.use(express.urlencoded({ extended: true }));
        app.use(express.static(path));
        ```
    - Install ejs
        ```
        npm install ejs
        ```
    - Update views/sharks.html file 
        ```
        <div class="container">
            <div class="row">
                <div class="col-lg-4">
                    <p>
                        <div class="caption">Some sharks are known to be dangerous to humans, though many more are not. The sawshark, for example, is not considered a threat to humans.
                        </div>
                        <img src="https://assets.digitalocean.com/articles/docker_node_image/sawshark.jpg" alt="Sawshark">
                    </p>
                </div>
                <div class="col-lg-4">
                    <p>
                        <div class="caption">Other sharks are known to be friendly and welcoming!</div>
                        <img src="https://assets.digitalocean.com/articles/docker_node_image/sammy.png" alt="Sammy the Shark">
                    </p>
                </div>
            <div class="col-lg-4">
                    <p>
                        <form action="/sharks/addshark" method="post">
                            <div class="caption">Enter Your Shark</div>
                            <input type="text" placeholder="Shark Name" name="name" <%=sharks[i].name; %>
                            <input type="text" placeholder="Shark Character" name="character" <%=sharks[i].character; %>
                            <button type="submit">Submit</button>
                        </form>
                    </p>
                </div>
            </div>
        </div>

        </html>
        ```
    - Make a copy of views/sharks.html to views/getshark.html
        ```
        cp views/sharks.html views/getshark.html
        ```
    - Modify the views/getshark.html
        ```
        ...
        <div class="container">
            <div class="row">
                <div class="col-lg-4">
                    <p>
                        <div class="caption">Some sharks are known to be dangerous to humans, though many more are not. The sawshark, for example, is not considered a threat to humans.
                        </div>
                        <img src="https://assets.digitalocean.com/articles/docker_node_image/sawshark.jpg" alt="Sawshark">
                    </p>
                </div>
                <div class="col-lg-4">
                    <p>
                        <div class="caption">Other sharks are known to be friendly and welcoming!</div>
                        <img src="https://assets.digitalocean.com/articles/docker_node_image/sammy.png" alt="Sammy the Shark">
                    </p>
                </div>
            <div class="col-lg-4">
                    <p>
                    <div class="caption">Your Sharks</div>
                        <ul>
                            <% sharks.forEach(function(shark) { %>
                                <p>Name: <%= shark.name %></p>
                                <p>Character: <%= shark.character %></p>
                            <% }); %>
                        </ul>
                    </p>
                </div>
            </div>
        </div>

        </html>
        ```
    - Update app.js
        ```
        ...
        app.engine('html', require('ejs').renderFile);
        app.set('view engine', 'html');
        app.use(express.urlencoded({ extended: true }));
        app.use(express.static(path));
        ...
        ```
    - Creating Routers 'mkdir routes && nano routes/index.js'
        ```
        const express = require('express');
        const router = express.Router();
        const path = require('path');

        router.use (function (req,res,next) {
        console.log('/' + req.method);
        next();
        });

        router.get('/',function(req,res){
        res.sendFile(path.resolve('views/index.html'));
        });

        module.exports = router;
        ```
    - Create routes/sharks.js
        ```
        const express = require('express');
        const router = express.Router();
        const shark = require('../controllers/sharks');

        router.get('/', function(req, res){
            shark.index(req,res);
        });

        router.post('/addshark', function(req, res) {
            shark.create(req,res);
        });

        router.get('/getshark', function(req, res) {
            shark.list(req,res);
        });

        module.exports = router;
        ```
    - Update app.js
        ```
        const express = require('express');
        const app = express();
        const router = express.Router();
        const db = require('./db');
        const sharks = require('./routes/sharks');

        const path = __dirname + '/views/';
        const port = 8080;

        app.engine('html', require('ejs').renderFile);
        app.set('view engine', 'html');
        app.use(express.urlencoded({ extended: true }));
        app.use(express.static(path));
        app.use('/sharks', sharks);

        app.listen(port, function () {
        console.log('Example app listening on port 8080!')
        })
        ```
    - Structure should look like inside 'node_project'
        ```
        ├── Dockerfile
        ├── README.md
        ├── app.js
        ├── controllers
        │   └── sharks.js
        ├── db.js
        ├── models
        │   └── sharks.js
        ├── package-lock.json
        ├── package.json
        ├── routes
        │   ├── index.js
        │   └── sharks.js
        └── views
            ├── css
            │   └── styles.css
            ├── getshark.html
            ├── index.html
            └── sharks.html
        ````
    - Modify firewall
        ```
        sudo ufw allow 8080
        ```
    - Start the application
        ```
        node app.js
        ```

