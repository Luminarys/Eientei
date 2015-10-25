// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

//var paste = document.getElementById("paste");
//var pasteBtn = document.getElementById("paste-btn");
var browse = document.getElementById('browse');

window.addEventListener('dragenter', dragNOP, false);
window.addEventListener('dragleave', dragNOP, false);
window.addEventListener('dragover', dragNOP, false);
window.addEventListener('drop', handleDragDrop, false);

document.querySelector(".target").addEventListener("click", function(e) {
    e.preventDefault();
    browse.click();
});

browse.addEventListener("change", function(e) {
    for (var i = 0; i < browse.files.length; i++) {
        var f = browse.files[i];
        var progress = addRow(f);
        uploadFile(f, progress);
    }
});

function addRow(file) {
    var row = document.createElement("tr");
    var name = document.createElement("td");
    name.textContent = file.name;
    var progressCell = document.createElement("td");
    var progress = document.createElement("div");
    progressCell.appendChild(progress);
    progress.className = "progress";
    var progressBar = document.createElement("div");
    progressBar.style.width = "0%";
    progressBar.textContent = "0%";
    progressBar.className = "progress-bar";
    progress.appendChild(progressBar);
    row.appendChild(name);
    row.appendChild(progressCell);
    document.getElementById("files").appendChild(row);
    return progressCell;
}

function dragNOP(e) {
    e.stopPropagation();
    e.preventDefault();
}

function handleDragDrop(e) {
    dragNOP(e);
    for (var i = 0; i < e.dataTransfer.files.length; i++) {
        var file = e.dataTransfer.files[i];
        var progress = addRow(file);
        uploadFile(file, progress);
    }
}

/*paste.addEventListener("keydown", function() {
    pasteBtn.style.display = 'block';
});
pasteBtn.addEventListener("click", function(e) {
    e.preventDefault();
    var blob = new Blob([paste.value], {type: "text/plain"});
    var file = new File([blob], "paste.txt");
    var progress = addRow(file);
    uploadFile(file, progress);
});/**/

function uploadFile(file, progress) {
    var bar = progress.querySelector(".progress-bar");
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "/api/upload");
    xhr.onload = function() {
        var respStatus = xhr.status;
        if (respStatus == 200) {
            var response = JSON.parse(xhr.responseText);
            if (response.success) {
                progress.innerHTML = "<a href='" + response.url + "'>" + response.name + "</a>";
            } else {
                progress.innerHTML = "Error: " + response.reason;
            }
        } else if (respStatus == 413) {
            progress.innerHTML = "File too big!";
        } else {
            progress.innerHTML = "Server error!";
        }
    };
    xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
            var progress = Math.floor((e.loaded / e.total) * 100);
            bar.style.width = progress + "%";
            bar.textContent = progress + "%";
        }
    };
    var form = new FormData();
    form.append("key", window.api_key);
    form.append("file", file);
    xhr.send(form);
}
