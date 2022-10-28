addEventListener("contextmenu", (event) => {
	event.preventDefault();
});

addEventListener("dragstart", (event) => {
	event.preventDefault();
});

let serverAddress = localStorage.getItem("serverAddress") || "http://dnascanner.dynv6.net:3000";

let token = location.href.split("?token=")[1].split("&")[0];
let username = decodeURIComponent(location.href.split("&username=")[1].split("&")[0]);
let opponentName = decodeURIComponent(location.href.split("&opponentName=")[1].split("?")[0]);
let board = location.href.split("?board=")[1].split("?")[0].split(",");
let won = location.href.split("?won=")[1].split("?")[0];
let player = location.href.split("?player=")[1].split("?")[0];
let winner = location.href.split("?winner=")[1].split("?")[0];

let lineEnd = document.getElementById("line-end");
let winnerText = document.getElementById("idk-how-the-fuck-i-should-call-this-please-let-me-out-of-your-basement");
let winnerElement = document.getElementById("winner");

let noDraw = false;

printBoard();

(async () => {
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
})();

function printBoard() {
	board.forEach(function callback(value, index) {
		if (player == 1) {
			if (value == 1) {
				setField(index, 1);
			}
			if (value == 2) {
				setField(index, 2);
			}
		}

		if (player == 2) {
			if (value == 1) {
				setField(index, 2);
			}
			if (value == 2) {
				setField(index, 1);
			}
		}

		if (value == 0) {
			setField(index, 0);
		}
	});
}

function setField(field, getPlayer) {
	if (getPlayer == 0) {
		document.getElementById(`p${field}`).src = "./src/blank.svg";
	}

	if (getPlayer == 1) {
		document.getElementById(`p${field}`).src = "./src/x.svg";
	}

	if (getPlayer == 2) {
		document.getElementById(`p${field}`).src = "./src/o.svg";
	}
}

function clickToBack() {
	document.getElementById("back-arrow").classList.add("back-arrow-ani");
	setTimeout(() => {
		location.href = `./waiting.html?token=${token}`;
	}, 500);
}

setTimeout(() => {
	if (board[0] == board[1] && board[1] == board[2] && board[0] != 0) {
		// x x x
		// - - -
		// - - -
		lineEnd.classList.add("horizontal-top");
		lineEnd.classList.remove("blank");
		noDraw = true;
	} else if (board[3] == board[4] && board[4] == board[5] && board[3] != 0) {
		// - - -
		// x x x
		// - - -
		lineEnd.classList.add("horizontal");
		lineEnd.classList.remove("blank");
		noDraw = true;
	} else if (board[6] == board[7] && board[7] == board[8] && board[6] != 0) {
		// - - -
		// - - -
		// x x x
		lineEnd.classList.add("horizontal-bottom");
		lineEnd.classList.remove("blank");
		noDraw = true;
	} else if (board[0] == board[3] && board[3] == board[6] && board[0] != 0) {
		// x - -
		// x - -
		// x - -
		lineEnd.classList.add("vertical-left");
		lineEnd.classList.remove("blank");
		noDraw = true;
	} else if (board[1] == board[4] && board[4] == board[7] && board[1] != 0) {
		// - x -
		// - x -
		// - x -
		lineEnd.classList.remove("blank");
		noDraw = true;
	} else if (board[2] == board[5] && board[5] == board[8] && board[2] != 0) {
		// - - x
		// - - x
		// - - x
		lineEnd.classList.add("vertical-right");
		lineEnd.classList.remove("blank");
		noDraw = true;
	} else if (board[0] == board[4] && board[4] == board[8] && board[0] != 0) {
		// x - -
		// - x -
		// - - x
		lineEnd.classList.add("diagonal-left");
		lineEnd.classList.remove("blank");
		noDraw = true;
	} else if (board[2] == board[4] && board[4] == board[6] && board[2] != 0) {
		// - - x
		// - x -
		// x - -
		lineEnd.classList.add("diagonal-right");
		lineEnd.classList.remove("blank");
		noDraw = true;
	}

	if (won == "true") {
		winnerText.innerHTML = `GG, <yellow>${username}</yellow>!`;
		winnerElement.innerHTML = `You won!`;
	} else if (!noDraw && !board.includes(0) && winner == "draw") {
		winnerText.innerHTML = `GG bro`;
		winnerElement.innerHTML = `You <yellow>both</yellow> are ass at this game!`;
	} else {
		winnerText.innerHTML = "Take the L";
		winnerElement.innerHTML = `You lost against <yellow>${opponentName}</yellow>!`;
	}
}, 250);

function error(message) {
	if (message === "incorrectPassword") {
		location.href = "./?error=incorrectPassword";
	} else if (message === "tooManyRequests") {
		location.href = "./?error=tooManyRequests";
	} else if (message === "noToken") {
		location.href = "./?error=noToken";
	} else if (message === "unknownUser") {
		location.href = "./?error=unknownUser";
	}
}
