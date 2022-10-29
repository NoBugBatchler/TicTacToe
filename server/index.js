/*===============================x
I  Made by DNAScanner with love  I
I     https://dnascanner.de      I
x===============================*/

import {} from "dotenv/config";
import express from "express";
import cors from "cors";
import fs from "fs";
import http from "http";
import https from "https";

const app = express();
const router = express.Router();

let users = [];
let matches = [];
let antiRequestSpam = [];

let sslCredentials = {}
let sslEnabled = false;

if (fs.existsSync("ssl/key.pem") && fs.existsSync("ssl/cert.pem")) {
	sslCredentials = {
		key: fs.readFileSync("ssl/key.pem", "utf8"),
		cert: fs.readFileSync("ssl/cert.pem", "utf8"),
	};
	sslEnabled = true;
}

fs.existsSync("restart.js") ? fs.unlinkSync("restart.js") : null;

async function loadData() {
	if (fs.existsSync("data.json")) {
		const data = JSON.parse(fs.readFileSync("data.json", "utf8"));
		users = data.users || [];
		matches = data.matches || [];
	}
}

await loadData();

app.use(express.json());
app.use(express.urlencoded({extended: true}));
app.use(
	cors({
		origin: "*",
	})
);
app.use(router);

// User statuses
// 0: Searching / Waiting for match
// 1: In match
// 3: Challenged you
// 4: You challenged them

router.post("/removetimeout", (req, res) => {
	const password = req.body.password;
	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			error: "incorrectPassword",
		});
		return;
	}

	antiRequestSpam = antiRequestSpam.map((user) => {
		if (req.ip === user.ip) {
			user.timeouted = false;
			user.requests = 0;
			user.timeoutRemoveAt = 0;
		}
		return user;
	});

	res.status(200).json({
		message: "success",
	});
});

router.use((req, res, next) => {
	users = users.map((user) => {
		if (user.ip === req.ip) {
			user.lastActiveTimestamp = Date.now();
		}
		return user;
	});

	let user = antiRequestSpam.find((user) => user.ip === req.ip);
	if (user) {
		user.requests++;
	} else {
		antiRequestSpam.push({
			ip: req.ip,
			requests: 1,
			timeouted: false,
			timeoutRemoveAt: 0,
		});
	}

	if (antiRequestSpam.find((user) => user.ip === req.ip).timeouted) {
		res.status(200).json({
			error: `tooManyRequests${Math.round((antiRequestSpam.find((user) => user.ip === req.ip).timeoutRemoveAt - Date.now()) / 1000)}s`,
		});
		return;
	}

	next();
});

router.get("/", (req, res) => {
	res.status(200).json({
		message: "up",
		messageFull: "Hello world, this is the TicTacToe API",
	});
});

router.post("/register", (req, res) => {
	const username = req.body.username;

	if (!username) {
		res.status(400).json({
			message: "noName",
		});
		return;
	}

	if (users.find((user) => user.username.toLowerCase() === username.toLowerCase())) {
		res.status(200).json({
			message: "nameTaken",
		});
		return;
	}

	const token = Math.random().toString(36).substr(2, 9);

	let newUser = {
		username,
		token,
		status: 0,
		match: null,
		symbol: null,
		challenged: [],
		ip: req.ip,
		id: Math.random().toString(36).substr(2, 9),
		createdTimestamp: Date.now(),
		lastActiveTimestamp: Date.now(),
	};

	users.push(newUser);
	res.status(200).json({
		message: "success",
		token,
		user: newUser,
	});
});

router.post("/getuser", (req, res) => {
	const token = req.body.token;

	if (!token) {
		res.status(200).json({
			message: "noToken",
		});
		return;
	}

	const user = users.find((user) => user.token === token);

	if (!user) {
		res.status(200).json({
			message: "unknownUser",
		});
		return;
	}

	res.status(200).json({
		message: "success",
		user,
	});
});

router.post("/getusers", (req, res) => {
	const token = req.body.token;

	if (!token) {
		res.status(200).json({
			message: "noToken",
		});
		return;
	}

	const user = users.find((user) => user.token === token);

	if (!user) {
		res.status(200).json({
			message: "unknownUser",
			user,
		});
		return;
	}

	let usersToSend = users.map((userToSend) => {
		if (userToSend.id === user.id) {
			return null;
		}

		let sendStatus = userToSend.status;

		if (userToSend.challenged.includes(user.id)) {
			sendStatus = 3;
		} else if (user.challenged.includes(userToSend.id)) {
			sendStatus = 4;
		}

		switch (sendStatus) {
			case 0:
				sendStatus = "searching";
				break;
			case 1:
				sendStatus = "inMatch";
				break;
			case 3:
				sendStatus = "challengedYou";
				break;
			case 4:
				sendStatus = "youChallenged";
				break;
		}

		return {
			username: userToSend.username,
			id: userToSend.id,
			status: sendStatus,
		};
	});

	usersToSend = usersToSend.filter((user) => user !== null);

	res.status(200).json({
		message: "success",
		users: usersToSend,
		user,
	});
});
/* Made by DNAScanner with love */
router.post("/challenge", (req, res) => {
	const token = req.body.token;
	const challengedUserId = req.body.user;

	if (!token) {
		res.status(200).json({
			message: "noToken",
		});
		return;
	}

	const user = users.find((user) => user.token === token);

	if (!user) {
		res.status(200).json({
			message: "unknownUser",
		});
		return;
	}

	if (user.match !== null) {
		res.status(200).json({
			message: "inMatch",
		});
		return;
	}

	const challengedUser = users.find((user) => user.id === challengedUserId);

	if (!challengedUser) {
		res.status(200).json({
			message: "unknownUser",
			user,
		});
		return;
	}

	if (user.challenged.includes(challengedUser.id)) {
		user.challenged.splice(user.challenged.indexOf(challengedUser.id), 1);

		res.status(200).json({
			message: "success",
			user,
		});
		return;
	}

	if (challengedUser.challenged.includes(user.id)) {
		const matchId = Math.random().toString(36).substr(2, 9);

		users.map((userFromGlobal) => {
			if (userFromGlobal.id === challengedUser.id || userFromGlobal.id === user.id) {
				userFromGlobal.status = 1;
				userFromGlobal.match = matchId;

				userFromGlobal.challenged = [];
			}
			return user;
		});

		matches.push({
			id: matchId,
			users: [user.id, challengedUser.id],
			board: [
				0, // Row 1, Column 1
				0, // Row 1, Column 2
				0, // Row 1, Column 3
				0, // Row 2, Column 1
				0, // Row 2, Column 2
				0, // Row 2, Column 3
				0, // Row 3, Column 1
				0, // Row 3, Column 2
				0, // Row 3, Column 3
			],
			turn: user.id,
			winner: null,
		});

		res.status(200).json({
			message: "matchCreated",
			match: matches.find((match) => match.id === matchId),
			user,
		});
		return;
	}

	user.challenged.push(challengedUser.id);

	res.status(200).json({
		message: "success",
		user,
	});
});

router.post("/place", (req, res) => {
	const token = req.body.token;
	const position = req.body.position;

	if (!token) {
		res.status(200).json({
			message: "noToken",
		});
		return;
	}

	const user = users.find((user) => user.token === token);

	if (!user) {
		res.status(200).json({
			message: "unknownUser",
		});
		return;
	}

	const match = matches.find((match) => match.id === user.match);

	if (!match) {
		res.status(200).json({
			message: "unknownMatch",
			user,
		});
		return;
	}
	/* Made by DNAScanner with love */
	if (match.winner) {
		res.status(200).json({
			message: "matchOver",
			user,
		});
		return;
	}

	if (match.turn !== user.id) {
		res.status(200).json({
			message: "notYourTurn",
			user,
		});
		return;
	}

	if (match.board[req.body.position] !== 0) {
		res.status(200).json({
			message: "positionTaken",
			user,
		});
		return;
	}

	match.board[position] = match.users.indexOf(user.id) + 1;

	match.turn = match.users.find((userId) => userId !== user.id);

	res.status(200).json({
		message: "success",
		match,
		user,
	});
});

router.post("/getmatch", (req, res) => {
	const token = req.body.token;

	if (!token) {
		res.status(200).json({
			message: "noToken",
		});
		return;
	}

	const user = users.find((user) => user.token === token);

	if (!user) {
		res.status(200).json({
			message: "unknownUser",
		});
		return;
	}
	/* Made by DNAScanner with love */
	const match = matches.find((match) => match.id === user.match);

	if (!match) {
		res.status(200).json({
			message: "unknownMatch",
			user,
		});
		return;
	}

	let matchDetails = JSON.parse(JSON.stringify(match));

	matchDetails.users = match.users.map((userId) => {
		const user = users.find((user) => user.id === userId);

		return {
			username: user.username,
			id: user.id,
		};
	});

	matchDetails.turn = users.find((user) => user.id === match.turn).username;

	if (match.winner && match.winner === "draw") {
		matchDetails.winner = "draw";
	} else if (match.winner) {
		matchDetails.winner = users.find((user) => user.id === match.users[match.winner - 1]).username;
	}

	matchDetails.turn = users.find((user) => user.id === match.turn);
	matchDetails.turn = {
		username: matchDetails.turn.username,
		id: matchDetails.turn.id,
	};
	matchDetails.yourTurn = matchDetails.turn.id === user.id ? true : false;

	res.status(200).json({
		message: "success",
		match: matchDetails,
		user,
	});
});

router.post("/leavematch", (req, res) => {
	const token = req.body.token;

	if (!token) {
		res.status(200).json({
			message: "noToken",
		});
		return;
	}

	const user = users.find((user) => user.token === token);

	if (!user) {
		res.status(200).json({
			message: "unknownUser",
		});
		return;
	}

	const match = matches.find((match) => match.id === user.match);

	if (!match) {
		res.status(200).json({
			message: "unknownMatch",
			user,
		});
		return;
	}

	match.winner == null ? (match.winner = "draw") : null;

	user.match = null;
	user.status = 0;

	res.status(200).json({
		message: "success",
		user,
	});
});

router.post("/logout", (req, res) => {
	const token = req.body.token;

	if (!token) {
		res.status(200).json({
			message: "noToken",
		});
		return;
	}

	const user = users.find((user) => user.token === token);

	if (!user) {
		res.status(200).json({
			message: "unknownUser",
		});
		return;
	}

	users.splice(users.indexOf(user), 1);

	res.status(200).json({
		message: "success",
		user,
	});
});

router.post("/stop", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}
	/* Made by DNAScanner with love */
	res.status(200).json({
		message: "success",
	});
	process.exit();
});

router.post("/restart", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	res.status(200).json({
		message: "success",
	});
	fs.writeFileSync("restart.js", `${Date.now()}`);
});

router.post("/getallusers", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	res.status(200).json({
		message: "success",
		users,
	});
});

router.post("/getallmatches", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	res.status(200).json({
		message: "success",
		matches,
	});
});

router.post("/modifymatch", (req, res) => {
	const password = req.body.password;
	const matchId = req.body.matchId;
	const action = req.body.action;
	/* Made by DNAScanner with love */
	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	if (!matchId) {
		res.status(200).json({
			message: "noMatchId",
		});
		return;
	}

	if (!action) {
		res.status(200).json({
			message: "noAction",
		});
		return;
	}

	const match = matches.find((match) => match.id === matchId);

	if (!match) {
		res.status(200).json({
			message: "unknownMatch",
		});
		return;
	}

	if (action === "end") {
		match.winner = match.users.find((userId) => userId !== match.turn);

		res.status(200).json({
			message: "success",
		});
	} else if (action === "delete") {
		matches.splice(matches.indexOf(match), 1);

		res.status(200).json({
			message: "success",
		});
	} else if (action === "reset") {
		match.board = [
			0, // Row 1, Column 1
			0, // Row 1, Column 2
			0, // Row 1, Column 3
			0, // Row 2, Column 1
			0, // Row 2, Column 2
			0, // Row 2, Column 3
			0, // Row 3, Column 1
			0, // Row 3, Column 2
			0, // Row 3, Column 3
		];
		match.turn = match.users[0];
		match.winner = null;

		res.status(200).json({
			message: "success",
		});
	} else if (action === "changeTurn") {
		match.turn = match.users.find((userId) => userId !== match.turn);

		res.status(200).json({
			message: "success",
		});
	} else if (action === "changeBoard") {
		match.board = req.body.board;

		res.status(200).json({
			message: "success",
		});
	} else {
		res.status(200).json({
			message: "unknownAction",
		});
		return;
	}
});

router.post("/clearusers", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	users = [];

	res.status(200).json({
		message: "success",
	});
});

router.post("/clearmatches", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	matches = [];

	res.status(200).json({
		message: "success",
	});
});

router.post("/clearall", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	users = [];
	matches = [];

	res.status(200).json({
		message: "success",
	});
});

router.post("/checkpassword", (req, res) => {
	const password = req.body.password;

	if (!password) {
		res.status(200).json({
			message: "noPassword",
		});
		return;
	}

	if (password !== process.env.PASSWORD) {
		res.status(200).json({
			message: "wrongPassword",
		});
		return;
	}

	res.status(200).json({
		message: "success",
	});
});

setInterval(async () => {
	users = users.filter((user) => {
		if (Date.now() - user.lastActiveTimestamp < 300000) {
			return true;
		}
		return false;
	});
	
	fs.writeFileSync("data.json", JSON.stringify({users, matches, antiRequestSpam}, null, 6));
	
	antiRequestSpam = antiRequestSpam.map((user) => {
		if (user.requests > 20 && !user.timeouted) {
			user.timeouted = true;
			user.timeoutRemoveAt = Date.now() + process.env.TIMEOUT_DURATION * 60000;
		}
		
		if (user.timeouted && Date.now() > user.timeoutRemoveAt) {
			user.timeouted = false;
			user.timeoutRemoveAt = 0;
			user.requests = 0;
		}
		
		if (!user.timeouted) {
			user.requests = 0;
		}
		/* Made by DNAScanner with love */
		return user;
	});
	
	matches.forEach((match) => {
		if (match.winner === null) {
			const board = match.board;
			
			if (board[0] === board[1] && board[1] === board[2] && board[0] !== 0) {
				// x x x
				// - - -
				// - - -
				match.winner = board[0];
			} else if (board[3] === board[4] && board[4] === board[5] && board[3] !== 0) {
				// - - -
				// x x x
				// - - -
				match.winner = board[3];
			} else if (board[6] === board[7] && board[7] === board[8] && board[6] !== 0) {
				// - - -
				// - - -
				// x x x
				match.winner = board[6];
			} else if (board[0] === board[3] && board[3] === board[6] && board[0] !== 0) {
				// x - -
				// x - -
				// x - -
				match.winner = board[0];
			} else if (board[1] === board[4] && board[4] === board[7] && board[1] !== 0) {
				// - x -
				// - x -
				// - x -
				match.winner = board[1];
			} else if (board[2] === board[5] && board[5] === board[8] && board[2] !== 0) {
				// - - x
				// - - x
				// - - x
				match.winner = board[2];
			} else if (board[0] === board[4] && board[4] === board[8] && board[0] !== 0) {
				// x - -
				// - x -
				// - - x
				match.winner = board[0];
			} else if (board[2] === board[4] && board[4] === board[6] && board[2] !== 0) {
				// - - x Made by DNAScanner with love
				// - x -
				// x - -
				match.winner = board[2];
			} else if (board.every((value) => value !== 0)) {
				// No one won
				match.winner = "draw";
			}
		}
	});
}, 500);

let httpServer = http.createServer(app);
let httpsServer = https.createServer(sslCredentials, app);

httpServer.listen(process.env.PORT, () => {
	console.log(`HTTP server running on port ${process.env.PORT}`);
})

if (sslEnabled) {
	httpsServer.listen(process.env.HTTPS_PORT, () => {
		console.log(`HTTPS server running on port ${process.env.HTTPS_PORT}`);
	})
}