addEventListener("contextmenu", (event) => {
	event.preventDefault();
});

addEventListener("dragstart", (event) => {
	event.preventDefault();
});

let serverAddress = localStorage.getItem("serverAddress") || "http://dnascanner.dynv6.net:3000";
let token = location.href.split("?token=")[1].split("&")[0];
let board;
let player;
let username;
let yourTurn;
let opponent;

let match = {};
let oldBoard;

setInterval(async () => {
	let matchRequestData = {
		token: token,
	};

	let match;

	await fetch(`${serverAddress}/getmatch`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify(matchRequestData),
	}).then(async (response) => {
		if (response.ok) {
			matchResponse = await response.json();
			match = matchResponse;

			board = match.match.board;
			player = match.match.users[0].id === match.user.id ? 1 : 2;
			username = match.user.username;
			opponent = match.match.users.find((user) => user.username != username).username;
			yourTurn = match.match.yourTurn;

			if (match.match.winner !== null) {
				if (match.match.winner == match.user.username) {
					location.href = `./end.html?token=${token}&username=${username}&opponentName=${match.match.users.find((user) => user.username !== username).username}?board=${board}?won=true?winner=${match.match.winner}?player=${player}`;
				} else {
					location.href = `./end.html?token=${token}&username=${username}&opponentName=${match.match.users.find((user) => user.username !== username).username}?board=${board}?won=false?winner=${match.match.winner}?player=${player}`;
				}
			}
		}
	});

	if (oldBoard !== board) {
		printBoard();
		oldBoard = board;
	}
}, 500);

async function setPoint(position) {
	if (yourTurn) {
		let setPointData = {
			token: token,
			position: position,
		};

		let setPointResponse;

		await fetch(`${serverAddress}/place`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify(setPointData),
		}).then(async (response) => {
			if (response.ok) {
				setPointResponse = await response.json();
			}
		});

		let matchRequestData = {
			token: token,
		};

		let match;

		await fetch(`${serverAddress}/getmatch`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify(matchRequestData),
		}).then(async (response) => {
			if (response.ok) {
				matchResponse = await response.json();
				match = matchResponse;
				board = match.match.board;
				player = match.match.users[0].id === match.user.id ? 1 : 2;
				username = match.user.username;
				yourTurn = match.match.yourTurn;
			}
		});

		if (oldBoard !== board) {
			printBoard();
			oldBoard = board;
		}
	}
}

function printBoard() {
	if (yourTurn) {
		document.getElementById("turn-name").classList.add("turn-you");
		document.getElementById("turn-name").innerText = "Your";
	}

	if (!yourTurn) {
		document.getElementById("turn-name").classList.remove("turn-you");
		document.getElementById("turn-name").innerText = `${opponent}'s`;
	}

	board.forEach(function callback(value, index) {
		if (player === 1) {
			if (value === 1) {
				setField(index, 1);
			}
			if (value === 2) {
				setField(index, 2);
			}
		}

		if (player === 2) {
			if (value === 1) {
				setField(index, 2);
			}
			if (value === 2) {
				setField(index, 1);
			}
		}

		if (value === 0) {
			setField(index, 0);
		}
	});
}

function setField(field, getPlayer) {
	if (getPlayer === 1) {
		document.getElementById(`p${field}`).classList.remove("blank");
		document.getElementById(`p${field}`).src = "./src/x.svg";
	}

	if (getPlayer === 2) {
		document.getElementById(`p${field}`).classList.remove("blank");
		document.getElementById(`p${field}`).src = "./src/o.svg";
	}
}

async function clickToBack() {
	let leaveMatchRequestData = {
		token: token,
	};

	await fetch(`${serverAddress}/leavematch`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify(leaveMatchRequestData),
	}).then(async (response) => {
		if (response.ok) {
			let leaveMatchResponse = await response.json();
			error(leaveMatchResponse.message);
		}
	});

	location.href = `./`
}