addEventListener("contextmenu", (event) => {
	event.preventDefault();
});

addEventListener("dragstart", (event) => {
	event.preventDefault();
});

let serverAddress = localStorage.getItem("serverAddress") || "http://dnascanner.dynv6.net:3000";
let token = location.href.split("?token=")[1].split("&")[0];
let list = document.getElementById("list");
let waitingState = 0;

let users = [];
let oldUsers = users;

updateList();

setInterval(async () => {
	if (oldUsers != users) {
		updateList();
		oldUsers = users;
	}
}, 1000);

async function updateList() {
	let getUsersData = {
		token: token,
	};

	let loginResponse;

	await fetch(`${serverAddress}/getusers`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify(getUsersData),
	}).then(async (response) => {
		if (response.ok) {
			loginResponse = await response.json();
			users = loginResponse.users;
		}
	});

	error(loginResponse.message);

	if (loginResponse.user.match !== null) {
		location.href = `match.html?token=${token}`;
	}

	// Check if users is empty
	if (users.length === 0) {
		if (waitingState === 0) {
                  list.innerHTML = `<h1 id="waiting-no-players" class="waiting-text">Waiting for players...</h1>`
            } else if (waitingState === 1) {
                  list.innerHTML = `<h1 id="waiting-no-players" class="waiting-text">Waiting for players..</h1>`
            } else if (waitingState === 2) {
                  list.innerHTML = `<h1 id="waiting-no-players" class="waiting-text">Waiting for players.</h1>`
            }

            waitingState === 2 ? waitingState = 0 : waitingState++;
	} else {
		list.innerHTML = users
			.map((user) => {
				let username = user.username;
				let userId = user.id;
				let status = user.status;
				let statusClass = `status-${status}`;

				// searching
				// inMatch
				// challengedYou
				// youChallenged

				if (status === "searching") {
					status = "Searching";
				} else if (status === "inMatch") {
					status = "In match";
				} else if (status === "challengedYou") {
					status = "Challenged you";
				} else if (status === "youChallenged") {
					status = "Challenged";
				}

				let text = `<div class="user" onclick="challenge('${userId}')"><h1 class="username">${username}</h1><h1 class="user-status ${statusClass}">${status}</h1></div>`;
				return text;
			})
			.join("");
	}
}

// challenge-failed -> red Border

async function challenge(userId) {
	let challengeData = {
		token: token,
		user: userId,
	};

	let challengeResponse;

	await fetch(`${serverAddress}/challenge`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify(challengeData),
	}).then(async (response) => {
		if (response.ok) {
			loginResponse = await response.json();
			challengeResponse = loginResponse;
		}
	});

	error(challengeResponse.message);

	if (challengeResponse.user.match !== null) {
		location.href = `match.html?token=${token}`;
	}
}

async function clickToBack() {
	document.getElementById("back-arrow").classList.add("back-arrow-ani");

	let logoutData = {
		token: token,
	};

	await fetch(`${serverAddress}/logout`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify(logoutData),
	}).then(async (response) => {
		if (response.ok) {
			let leaveMatchResponse = await response.json();
			if (leaveMatchResponse.message === "success") {
				location.href = "./";
			} else {
				error(leaveMatchResponse.message);
			}
		}
	});

	setTimeout(() => {
		location.href = `./index.html`;
	}, 500);
}

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
