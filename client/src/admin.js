addEventListener("contextmenu", (event) => {
	event.preventDefault();
});

addEventListener("dragstart", (event) => {
	event.preventDefault();
});

let adminPassword = localStorage.getItem("adminPassword");
let serverAddress = localStorage.getItem("serverAddress") || "http://dnascanner.dynv6.net:3000";

let passwordInput = document.getElementById("password-input");
let categoryList = document.getElementById("category-list");
let menuPlayers = document.getElementById("menu-players");
let menuMatches = document.getElementById("menu-matches");

setInterval(async () => {
	if (await checkAdminPassword()) {
            passwordInput.classList.remove("password-error");
            passwordInput.classList.add("password-correct");
            categoryList.classList.remove("category-list-block");
      } else {
            passwordInput.classList.remove("password-correct");
            passwordInput.classList.add("password-error");
            categoryList.classList.add("category-list-block");
      }
}, 500);

function clickToBack() {
	window.close();
}

async function requestPassword() {
      if (!await checkAdminPassword()) {
            adminPassword = prompt("Enter admin password");

            if (!adminPassword) {
                  alert("Password is required");
            }

            localStorage.setItem("adminPassword", adminPassword);

            if (await checkAdminPassword()) {
                  passwordInput.classList.remove("password-error");
                  passwordInput.classList.add("password-correct");
            } else {
                  passwordInput.classList.remove("password-correct");
                  passwordInput.classList.add("password-error");
            }
      }
}

async function stopServer() {
      if (await checkAdminPassword()) {
            let stopServerData = {
                  password: adminPassword || "",
            }

            let stopServerResponse = ""

            await fetch(`${serverAddress}/stop`, {
                  method: "POST",
                  headers: {
                        "Content-Type": "application/json",
                  },
                  body: JSON.stringify(stopServerData),
            }).then(async (response) => {
                  if (response.ok) {
                        let stopServerData = await response.json();
                        stopServerResponse = stopServerData.message;
                  }
            })
            if (stopServerResponse == "success") {
                  alert("Server stopped");
            } else {
                  alert("Server stop failed");
            }
      }
}

async function restartServer() {
      if (await checkAdminPassword()) {
            let restartServerData = {
                  password: adminPassword || "",
            }

            let restartServerResponse = ""

            await fetch(`${serverAddress}/restart`, {
                  method: "POST",
                  headers: {
                        "Content-Type": "application/json",
                  },
                  body: JSON.stringify(restartServerData),
            }).then(async (response) => {
                  if (response.ok) {
                        let restartServerData = await response.json();
                        restartServerResponse = restartServerData.message;
                  }
            })
            if (restartServerResponse == "success") {
                  alert("Server restarted");
            } else {
                  alert("Server restart failed");
            }
      }
}

async function clearUsers() {
      if (await checkAdminPassword()) {
            let clearUsersData = {
                  password: adminPassword || "",
            }

            let clearUsersResponse = ""

            await fetch(`${serverAddress}/clearusers`, {
                  method: "POST",
                  headers: {
                        "Content-Type": "application/json",
                  },
                  body: JSON.stringify(clearUsersData),
            }).then(async (response) => {
                  if (response.ok) {
                        let clearUsersData = await response.json();
                        clearUsersResponse = clearUsersData.message;
                  }
            })
            if (clearUsersResponse == "success") {
                  alert("Users cleared");
            } else {
                  alert("Users clear failed");
            }
      }
}

async function clearMatches() {
      if (await checkAdminPassword()) {
            let clearMatchesData = {
                  password: adminPassword || "",
            }

            let clearMatchesResponse = ""

            await fetch(`${serverAddress}/clearmatches`, {
                  method: "POST",
                  headers: {
                        "Content-Type": "application/json",
                  },
                  body: JSON.stringify(clearMatchesData),
            }).then(async (response) => {
                  if (response.ok) {
                        let clearMatchesData = await response.json();
                        clearMatchesResponse = clearMatchesData.message;
                  }
            })
            if (clearMatchesResponse == "success") {
                  alert("Matches cleared");
            } else {
                  alert("Matches clear failed");
            }
      }
}

async function clearAll() {
      if (await checkAdminPassword()) {
            let clearAllData = {
                  password: adminPassword || "",
            }

            let clearAllResponse = ""

            await fetch(`${serverAddress}/clearall`, {
                  method: "POST",
                  headers: {
                        "Content-Type": "application/json",
                  },
                  body: JSON.stringify(clearAllData),
            }).then(async (response) => {
                  if (response.ok) {
                        let clearAllData = await response.json();
                        clearAllResponse = clearAllData.message;
                  }
            })
            if (clearAllResponse == "success") {
                  alert("All data cleared");
            } else {
                  alert("All data clear failed");
            }
      }
}

async function toggleMenuPlayers() {
      if (await checkAdminPassword()) {
            if (menuPlayers.style.display == "none") {
                  menuPlayers.style.display = "block";
            } else {
                  menuPlayers.style.display = "none";
            }
      }
}

async function toggleMenuMatches() {
      if (await checkAdminPassword()) {
            if (menuMatches.style.display == "none") {
                  menuMatches.style.display = "block";
            } else {
                  menuMatches.style.display = "none";
            }
      }
}

async function checkAdminPassword() {
      let checkAdminPasswordData = {
            password: adminPassword || "",
      }

      let checkAdminPasswordResponse = ""

      await fetch(`${serverAddress}/checkpassword`, {
            method: "POST",
            headers: {
                  "Content-Type": "application/json",
            },
            body: JSON.stringify(checkAdminPasswordData),
      }).then(async (response) => {
            if (response.ok) {
                  let passwordCheckData = await response.json();
                  checkAdminPasswordResponse = passwordCheckData.message;
            }
      })
      if (checkAdminPasswordResponse == "success") {
            return true;
      } else {
            return false;
      }
}
