addEventListener("contextmenu", (event) => {
	event.preventDefault();
});

addEventListener("dragstart", (event) => {
	event.preventDefault();
});

let serverAddress = localStorage.getItem("serverAddress") || "http://dnascanner.dynv6.net:3000";
const nameInputField = document.getElementById("name-input-field");
const nameInputButton = document.getElementById("name-input-login-button");
const customServerDisplay = document.getElementById("custom-server-current");
const customServerInput = document.getElementById("custom-server-input-field");

// Check, if the url contains error (?error=)
if (location.href.includes("error=")) {
	let error = location.href.split("error=")[1];

	alert(error);
}

setInterval(() => {
	localStorage.setItem("serverAddress", serverAddress);
	customServerDisplay.innerHTML = serverAddress;
}, 500);

function closeCustomServerInput() {
	document.getElementById("custom-server-input").classList.add("hidden");
	document.getElementById("toggle-server-input").classList.remove("hidden");
}

function openCustomServerInput() {
	document.getElementById("toggle-server-input").classList.add("hidden");
	document.getElementById("custom-server-input").classList.remove("hidden");
}

async function tryLogin() {
	let name = nameInputField.value;

	if (name.length > 0) {
		let loginData = {
			username: name,
		};

		let loginResponse;

		// Send login data to server via POST request
		await fetch(`${serverAddress}/register`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify(loginData),
		}).then(async (response) => {
			if (response.ok) {
				loginResponse = await response.json();
			}
		});

		if (loginResponse.message !== "success") {
			nameInputField.classList.remove("login-success");
			nameInputField.classList.remove("login-failed");
			nameInputField.classList.add("login-failed");

			setTimeout(() => {
				nameInputField.classList.remove("login-failed");
			}, 2000);
		} else {
			nameInputField.classList.remove("login-success");
			nameInputField.classList.remove("login-failed");
			nameInputField.classList.add("login-success");
			nameInputField.disabled = true;
			nameInputButton.onclick = "";

			setTimeout(() => {
				nameInputField.classList.remove("login-success");
				location.href = `./waiting.html?token=${loginResponse.token}`;
			}, 2000);
		}
	} else {
		nameInputField.classList.remove("login-success");
		nameInputField.classList.remove("login-failed");
		nameInputField.classList.add("login-failed");

		setTimeout(() => {
			nameInputField.classList.remove("login-failed");
		}, 2000);
	}
}

async function submitServer() {
	let newServer = customServerInput.value;

	if (newServer.length > 0) {
		// Check if the url is valid, http(s)://test.example.com:1324
		if (newServer.match(/^(http|https):\/\/[a-zA-Z0-9-_.]+(:[0-9]+)?$/)) {
			try {
				await fetch(`${newServer}/`).then(async (response) => {
					if (response.ok) {
						const serverResponse = await response.json();
						if (serverResponse.message === "up") {
							serverAddress = newServer;
							closeCustomServerInput();
						} else {
							customServerInput.classList.remove("login-success");
							customServerInput.classList.remove("login-failed");
							customServerInput.classList.add("login-failed");

							setTimeout(() => {
								customServerInput.classList.remove("login-failed");
							}, 2000);
						}
					}
				});
			} catch (error) {
				customServerInput.classList.remove("login-success");
				customServerInput.classList.remove("login-failed");
				customServerInput.classList.add("login-failed");

				setTimeout(() => {
					customServerInput.classList.remove("login-failed");
				}, 2000);
			}
		} else {
			customServerInput.classList.remove("login-success");
			customServerInput.classList.remove("login-failed");
			customServerInput.classList.add("login-failed");

			setTimeout(() => {
				customServerInput.classList.remove("login-failed");
			}, 2000);
		}
	} else {
		customServerInput.classList.remove("login-success");
		customServerInput.classList.remove("login-failed");
		customServerInput.classList.add("login-failed");

		setTimeout(() => {
			customServerInput.classList.remove("login-failed");
		}, 2000);
	}
}

function openAdminPopup() {
	closeCustomServerInput()

	setTimeout(() => {
		let adminWindow = window.open("./admin.html", "admin", "width=400,height=400")
	}, 250);
}

nameInputField.addEventListener("keypress", (event) => {
	if (event.key === "Enter") {
		tryLogin();
	}
});

customServerInput.addEventListener("keypress", (event) => {
	if (event.key === "Enter") {
		submitServer();
	}
});
