const express = require("express");
const http = require('http');
const server = http.createServer();
const io = require('socket.io')(server);
const BodyParser = require("body-parser");
const request = require("express");
const mongoose = require("mongoose");
const session = require("express-session");
const passport = require("passport");
const passportLocalMongoose = require("passport-local-mongoose");
const app = express();
const shortid = require('shortid');



mongoose.connect("mongodb://localhost:27017", { useNewUrlParser: true });
app.set("view engine", "ejs");
app.use(session({
  secret: 'Secret key',
  resave: false,
  saveUninitialized: true,
}))

app.use(passport.initialize());
app.use(passport.session());

const userSchema = new mongoose.Schema({
  username: String,
  password: String,
});

const memberSchema = new mongoose.Schema({
  name: String,
  location: {
    latitude: Number,
    longitude: Number
  }
});

const roomSchema = new mongoose.Schema({
  userID: String,
  roomname: String,
  roomID: String,
  hostkey: String,
  roomclose: Boolean,
  schedule: Date,
  drone: Boolean,
  member: [memberSchema]
});

const Room = mongoose.model("Room", roomSchema);

userSchema.plugin(passportLocalMongoose);

const User = mongoose.model("User", userSchema);

passport.use(User.createStrategy());

passport.serializeUser(User.serializeUser());
passport.deserializeUser(User.deserializeUser());

app.use(express.static("public"));
app.use(BodyParser.urlencoded({ extended: true }));


app.get("/", function(req, res) {
  res.sendFile(__dirname + "/home.html");
});

app.get("/authantication", function(req, res) {
  res.sendFile(__dirname + "/authantication.html");
});

app.get("/dashboard", function(req, res) {
  if (req.isAuthenticated()) {
    Room.find({ userID: req.user._id })
      .then(room => {
        res.render("dashboard", { room: room });
      })
      .catch(err => {
        console.error(err);
      });
  }
  else {
    res.redirect('/authantication');
  }
});

app.get("/Creating_room", function(req, res) {
  if (req.isAuthenticated()) {
    console.log(req.user);
    res.sendFile(__dirname + "/Creating_room.html");
  }
  else {
    res.redirect('/authantication');
  }
});

app.post("/Creating_room", function(req, res) {
  if (req.isAuthenticated()) {
    const room = new Room({
      userID: req.user._id,
      roomname: req.body.roomname,
      roomID: shortid.generate()
    });
    room.save()
      .then(savedRoom => {
        res.redirect('/map');
      })
      .catch(err => {
        console.log('Error saving room: ', err);
        return;
      });
  }
  else {
    res.redirect('/authantication');
  }
});

app.post("/login", function(req, res) {
  const user = new User({
    username: req.body.username,
    password: req.body.password
  });

  req.login(user, function(err) {
    if (err) {
      console.log(err);
      res.send("error");
    } else {
      passport.authenticate('local', { failureRedirect: '/authantication' })(req, res, function() {
        res.redirect('dashboard');
      });
    }
  });
});

app.post("/signup", function(req, res) {
  User.register({ username: req.body.username }, req.body.password, function(err, user) {
    if (err) {
      console.log(err);
      res.send("error");
    } else {
      res.redirect('/authantication');
    }
  });
});

app.post("/location", function(req, res) {
  Room.findOne({ roomname: req.body.roomcode })
    .then(existingRoom => {
      if (existingRoom.length === 0) {
        throw { empty: true };
      }
      existingRoom.member.forEach(member => {
        console.log(`${member.name}: ${member.location.latitude}, ${member.location.longitude}`);
      });
      const index = existingRoom.member.findIndex(member => member.name === req.body.id);
      if (index >= 0) {
        existingRoom.member[index].location = {
          latitude: req.body.lat,
          longitude: req.body.lon
        };
      } else {
        existingRoom.member.push({
          name: req.body.id,
          location: {
            latitude: req.body.lat,
            longitude: req.body.lon
          }
        });
      }
      return existingRoom.save();
    })
    .then(savedRoom => {
      console.log('Room saved successfully!');
      res.send('ok');
    })
    .catch(err => {
      if (err.empty) {
        console.log('No matching rooms found');
      }
      console.log('Error saving room: ', err);
      res.status(500).send('Error saving room');
    });

});

app.get("/logout", function(req, res) {
  req.logout(function(err) {
    if (err) { return next(err); }
    res.redirect('/');
  });
});

app.get("/map/api/:roomID", function(req, res) {
  const roomID = req.params.roomID;
  if (req.isAuthenticated()) {
    Room.find({ userID: req.user._id, roomID: roomID })
      .then(room => {
        if (room.length === 0) {
          throw { empty: true };
        }
        res.send(room);
      })
      .catch(err => {
        if (err.empty) {
          console.log('No matching rooms found');
        }
        else {
          console.error(err);
        }
        res.send("wrong room id");
      });
  }
  else {
    res.redirect('/authantication');
  }
});

app.get('/map/:roomID', (req, res) => {
  const roomID = req.params.roomID;
  if (req.isAuthenticated()) {
    Room.find({ userID: req.user._id, roomID: roomID })
      .then(room => {
        if (room.length === 0) {
          throw { empty: true };
        }
        res.render("map", { room: room });
      })
      .catch(err => {
        if (err.empty) {
          console.log('No matching rooms found');
        }
        else {
          console.error(err);
        }
        res.send("wrong room id");
      });
  }
  else {
    res.redirect('/authantication');
  }
});


app.listen(3000, console.log("3000")); 