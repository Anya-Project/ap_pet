window.addEventListener("message", function (event) {
  let data = event.data;

  if (data.action === "showHUD") {
    document.getElementById("pet-hud").style.display = "block";
  } else if (data.action === "hideHUD") {
    document.getElementById("pet-hud").style.display = "none";
  } else if (data.action === "updateHUD") {
    if (data.name) document.getElementById("pet-name").innerText = data.name;

    if (data.health !== undefined)
      document.getElementById("bar-health").style.width = data.health + "%";
    if (data.hunger !== undefined)
      document.getElementById("bar-hunger").style.width = data.hunger + "%";
    if (data.thirst !== undefined)
      document.getElementById("bar-thirst").style.width = data.thirst + "%";

    if (data.status) {
      let statusEl = document.getElementById("pet-status");
      if (data.status === "following") {
        statusEl.innerHTML =
          '<i class="fa-solid fa-person-walking"></i> Following';
      } else if (data.status === "sitting") {
        statusEl.innerHTML = '<i class="fa-solid fa-chair"></i> Sitting';
      } else if (data.status === "attacking") {
        statusEl.innerHTML =
          '<i class="fa-solid fa-khanda" style="color: #ff4d4d;"></i> Attacking!';
      }
    }
  }
});
